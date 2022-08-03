# Publish to the website database as quick as you can, please.
require "set"

class Publisher
  attr_accessor :resource

  SKIP_METADATA_PRED_URIS = Set.new([
    "http://rs.tdwg.org/dwc/terms/lifestage",
    "http://rs.tdwg.org/dwc/terms/sex"
  ])

  TRAIT_HEADS = %i[eol_pk page_id scientific_name resource_pk predicate sex lifestage statistical_method
    object_page_id target_scientific_name value_uri literal measurement units normal_measurement
    normal_units_uri sample_size citation source remarks method contributor_uri compiler_uri determined_by_uri]

  META_HEADS = %i[eol_pk trait_eol_pk predicate literal measurement value_uri units sex lifestage
    statistical_method source is_external]

  MAX_TRAIT_BATCH_SIZE = 1_000_000
  MAX_ASSOC_BATCH_SIZE = 1_000_000

  def self.by_resource(resource_in, process, harvest)
    new(resource_in, process, harvest).by_resource
  end

  def self.first
    publisher = new(resource: Resource.native)
    publisher.by_resource
    publisher
  end

  def initialize(resource, process, harvest)
    @resource = resource
    @process = process
    @model_mapper = WebDb::ModelMapper.new(@resource, @process)
    @trait_filename = harvest.trait_filename
    @web_resource_id = nil
    @files = {}
    @nodes = {}
    @traits = {}
    @assocs = {}
    @pages = {}
    @referents = {} # This will store ALL of the referents (the acutal text), and will persist over batches.
    @stored_refs = {} # This will store ref keys that we're already loaded, so we don't do it twice... [sigh]
    @bib_cits = {} # This will store ALL of the bibliographic_citations (the acutal text), and will persist.
    @stored_bib_cits = {} # This will store bib_cit keys that we're already loaded, so we don't do it twice.
    @locs = {} # This will store ALL of the locations (the acutal values), and will persist.
    @stored_locs = {} # This will store location keys that we're already loaded, so we don't do it twice.
    @limit = 10_000
    reset_vars
  end

  def reset_vars
    @nodes_by_pk = {}
    # TODO: We no longer need these to be hashes...
    @identifiers_by_node_pk = {}
    @ancestors_by_node_pk = {}
    @sci_names_by_node_pk = {}
    @media_by_node_pk = {}
    @articles_by_node_pk = {}
    @image_info_by_node_pk = {}
    @vernaculars_by_node_pk = {}
    @references = []
    @attributions = []
    @content_sections = []
  end

  def by_resource
    @process.run_step('overall_tsv_creation') do
      learn_resource_publishing_id
      WebDb.init
      create_tsv
    end
    @process.info('Done. Check your files:')
    @files.each_key { |file| safely_log_file_size(file) }
  end

  def safely_log_file_size(file)
    size = 0
    begin
      sizes = `wc -l #{file}`
      size = sizes.strip.split.first.to_i
      @process.info("(#{size} lines) #{file}")
    rescue Errno::ENOMEM
      raise('OUT OF MEMORY. This is NOT a problem for this resource (really, it isn\'t), but means that you should '\
            'have someone restart the containers!')
    end
  end

  def create_tsv
    @nodes = @resource.nodes
                      .includes(:identifiers, :node_ancestors, :references, :scientific_name,
                                vernaculars: [:language], scientific_names: [:dataset, :references],
                                media: %i[node license language references bibliographic_citation location] <<
                                  { content_attributions: :attribution },
                                articles: %i[node license language references bibliographic_citation location
                                             articles_sections] <<
                                  { content_attributions: :attribution })
    total_count = 0 # Scope
    processed_count = 0
    if start_with_node_id = read_highest_node_id
      total_count = @resource.nodes.where(['id > ?', start_with_node_id]).count
      @nodes = @nodes.where(['nodes.id > ?', start_with_node_id])
      @process.info("It looks like we have already exported up to node #{start_with_node_id}, resuming.")
      @process.info("Exporting another #{total_count} nodes as TSV in batches of #{@limit}...")
    else
      total_count = @resource.nodes.count
      @process.info("Exporting #{total_count} nodes as TSV in batches of #{@limit}...")
      remove_existing_pub_files
    end
    @process.in_batches(@nodes, @limit) do |nodes|
      reset_vars
      nodes_to_hashes(nodes) # This takes a about 75 seconds for a batch of 10K
      count_children # super-fast (about a 20th of a second)
      load_hashes # A few seconds
      build_traits(nodes)
      processed_count += nodes.size
      @process.info("Processed #{processed_count}/#{total_count} nodes")
      write_highest_node_id(nodes.last.id)
    end
    remove_highest_node_id_file
  end

  def read_highest_node_id
    return nil unless File.exist?(highest_node_id_filename)
    File.read(highest_node_id_filename).to_i
  end

  def write_highest_node_id(node_id)
    File.open(highest_node_id_filename, 'w') { |file| file.write(node_id) }
  end

  def remove_highest_node_id_file
    File.delete(highest_node_id_filename) if File.exist?(highest_node_id_filename)
  end

  def highest_node_id_filename
    @highest_node_id_filename ||= @resource.path.join('highest_tsv_node_id.txt')
  end

  def nodes_to_hashes(nodes)
    nodes.each do |node|
      build_page(node)
      next if @nodes_by_pk.key?(node.resource_pk)

      node_to_struct(node)
      build_identifiers(node)
      build_ancestors(node)
      build_scientific_names(node)
      build_media(node)
      build_articles(node)
      build_vernaculars(node)
    end
  end

  def node_to_struct(node)
    web_node = @model_mapper.node_to_struct(node)
    timestamp(web_node)
    web_node.parent_id = node.parent_id # NOTE this is a HARV DB ID. We need to update it.
    @nodes_by_pk[node.resource_pk] = web_node
    add_refs(node)
  end

  def add_refs(object)
    object.references.each do |ref|
      next if @referents.key?(ref.id)

      referent = @model_mapper.referant_to_struct(ref)
      timestamp(referent)
      @referents[ref.id] = referent
      reference = @model_mapper.reference_to_struct(object)
      reference.parent_id = object.id # NOTE: this is a HARV DB ID and should be replaced later.
      reference.referent_id = ref.id # NOTE: this is also a harv ID, and will need to be replaced.
      @references << reference
    end
  end

  def add_attributions(object)
    object.content_attributions.each do |content_attribution|
      next unless content_attribution.attribution

      attribution = @model_mapper.attribution_to_struct(content_attribution)
      timestamp(attribution)
      @attributions << attribution
    end
  end

  def add_sections(object, type)
    object.articles_sections.each do |articles_section|
      section = @model_mapper.section_to_struct(object, articles_section)
      @content_sections << section
    end
  end

  def add_bib_cit(object, citation)
    return if citation.nil?

    # NOTE: THIS ID IS WRONG! This is the *harv_db* ID. We're going to update it later, we're using this as a bridge.
    object.bibliographic_citation_id = citation.id
    return if @bib_cits.key?(citation.id)

    bc = @model_mapper.citation_to_struct(citation)
    timestamp(bc)
    @bib_cits[citation.id] = bc
  end

  def add_loc(object, loc)
    return if loc.nil?

    # NOTE: THIS ID IS WRONG! This is the *harv_db* ID. We're going to update it later, we're using this as a bridge.
    object.location_id = loc.id
    return if @locs.key?(loc.id)

    @locs[loc.id] = @model_mapper.location_to_struct(loc)
  end

  def build_page(node)
    if @pages.key?(node.page_id)
      update_page(node)
    else
      build_new_page(node)
    end
  end

  # This is NOT in the model mapper because it is HIGHLY dependent on the information provided by this class. You cannot
  # create a Page without creating all of the "things" on the page at the same time, so it does not make sense there.
  def build_new_page(node)
    @pages[node.page_id] = Struct::WebPage.new
    @pages[node.page_id].id = node.page_id
    timestamp(@pages[node.page_id])
    @pages[node.page_id].articles_count = node.articles.size
    @pages[node.page_id].nodes_count = 1 # This one, silly!
    @pages[node.page_id].vernaculars_count = node.vernaculars.size
    @pages[node.page_id].scientific_names_count = node.scientific_names.size
    @pages[node.page_id].articles_count = node.articles.size
    @pages[node.page_id].referents_count = node.references.size
    # TODO: all of these 0s should be populated, once we have the associations included:
    @pages[node.page_id].maps_count = 0 # TODO
    # These are NOT used by our code, but are required by the database (and thus we avoid inserting nulls):
    @pages[node.page_id].links_count = 0
    @pages[node.page_id].page_contents_count = 0
    @pages[node.page_id].species_count = 0
    @pages[node.page_id].is_extinct = 0
    @pages[node.page_id].is_marine = 0
    @pages[node.page_id].has_checked_extinct = 0
    @pages[node.page_id].has_checked_marine = 0
  end

  def update_page(node)
    # I am not sure why this happens, but it does. (?)
    @pages[node.page_id].nodes_count ||= 0
    @pages[node.page_id].media_count ||= 0
    @pages[node.page_id].articles_count ||= 0
    @pages[node.page_id].vernaculars_count ||= 0
    @pages[node.page_id].scientific_names_count ||= 0
    @pages[node.page_id].referents_count ||= 0
    @pages[node.page_id].nodes_count += 1
    @pages[node.page_id].media_count += node.media.size
    @pages[node.page_id].articles_count += node.articles.size
    @pages[node.page_id].vernaculars_count += node.vernaculars.size
    @pages[node.page_id].scientific_names_count += node.scientific_names.size
    @pages[node.page_id].referents_count += node.references.size
    # TODO: add counts for maps
  end

  def build_identifiers(node)
    node.identifiers.each do |ider|
      @identifiers_by_node_pk[node.resource_pk] ||= []
      web_id = identifier_to_struct(node, ider)
      web_id.node_id = ider.node_id # NOTE: this is a HARV DB ID. We will convert it later.
      @identifiers_by_node_pk[node.resource_pk] << web_id
    end
  end

  def build_ancestors(node)
    node.node_ancestors.each do |nodan|
      @ancestors_by_node_pk[node.resource_pk] ||= []
      anc = @model_mapper.node_ancestor_to_struct(node, nodan)
      anc.node_id = nodan.node_id # NOTE: this is a HARV DB ID. We will convert it later.
      anc.ancestor_id = nodan.ancestor_id # NOTE: this is a HARV DB ID. We will convert it later.
      @ancestors_by_node_pk[node.resource_pk] << anc
    end
  end

  def build_scientific_names(node)
    node.scientific_names.each do |name_model|
      @sci_names_by_node_pk[node.resource_pk] ||= []
      web_sci_name = @model_mapper.scientific_name_to_struct(node, name_model)
      timestamp(web_sci_name)
      web_sci_name.node_id = node.id # NOTE: this is a HARV DB ID. We will convert it later.
      @sci_names_by_node_pk[node.resource_pk] << web_sci_name
      add_refs(name_model)
    end
  end

  def build_media(node)
    node.media.each do |medium|
      @media_by_node_pk[node.resource_pk] ||= []
      web_medium = @model_mapper.medium_to_struct(node, medium)
      timestamp(web_medium)
      @media_by_node_pk[node.resource_pk] << web_medium
      add_refs(medium)
      add_attributions(medium)
      add_bib_cit(web_medium, medium.bibliographic_citation)
      add_loc(web_medium, medium.location)
      if medium.w && medium.h
        @image_info_by_node_pk[node.resource_pk] ||= []
        ii = @model_mapper.image_info_to_struct(medium)
        timestamp(ii)
        ii.medium_id = medium.id # NOTE this is a HARV DB ID, and needs to be replaced.
        @image_info_by_node_pk[node.resource_pk] << ii
      end
    end
  end

  def build_articles(node)
    node.articles.each do |article|
      @articles_by_node_pk[node.resource_pk] ||= []
      web_article = @model_mapper.article_to_struct(node, article)
      timestamp(web_article)
      @articles_by_node_pk[node.resource_pk] << web_article
      add_refs(article)
      add_attributions(article)
      add_sections(article, 'Article')
      add_bib_cit(web_article, article.bibliographic_citation)
      add_loc(web_article, article.location)
    end
  end

  def build_vernaculars(node)
    node.vernaculars.each do |vernacular|
      @vernaculars_by_node_pk[node.resource_pk] ||= []
      web_vern = @model_mapper.vernacular_to_struct(node, vernacular)
      timestamp(web_vern)
      web_vern.node_id = node.id # NOTE: this is a HARV DB ID. We will convert it later.
      web_vern.is_preferred = 0 # This will be fixed by the code run on the website.
      web_vern.trust = 0
      @vernaculars_by_node_pk[node.resource_pk] << vern
    end
  end

  def build_traits(nodes)
    return unless Trait.where(node_id: nodes.map(&:id)).any? ||
                  Assoc.where(node_id: nodes.map(&:id)).any?
    manage_size_of_nodes_for_traits(nodes) do |nodes_batch|
      build_batch_of_traits(nodes_batch)
    end
  end

  def manage_size_of_nodes_for_traits(nodes)
    start_node = 0
    last_node = nodes.size - 1
    loop do
      last_node = nodes.size - 1 # It's always greedy and tries to complete the rest of the batch
      while(too_many_trait_operations(nodes[start_node..last_node]) && start_node < last_node)
        last_node = ((last_node - start_node) / 2.0).round
        last_node = start_node if last_node < start_node
      end
      build_batch_of_traits(nodes[start_node..last_node])
      write_highest_node_id(nodes[last_node].id)
      start_node = last_node + 1
      break if start_node >= nodes.size
    end
  end

  def too_many_trait_operations(nodes)
    trait_count = Trait.where(node_id: nodes.map(&:id)).count
    assoc_count = Assoc.where(node_id: nodes.map(&:id)).count
    if trait_count <= MAX_TRAIT_BATCH_SIZE && assoc_count <= MAX_ASSOC_BATCH_SIZE
      @process.info("#{trait_count} Traits (unfiltered) and #{assoc_count} associations...")
      return false
    end
    true
  end

  def build_batch_of_traits(nodes)
    node_ids = nodes.map(&:id)
    trait_map(node_ids)
    assoc_map(node_ids)
    meta_file = @resource.publish_table_path('metadata')
    start_traits_file(@trait_filename, TRAIT_HEADS)
    start_traits_file(meta_file, META_HEADS)

    # metadata (child Traits) with parent Traits from resources other than the current one (specified by parent_eol_pk)
    external_trait_metas = @resource.traits
      .includes(:parent, :references)
      .where('traits.parent_eol_pk IS NOT NULL AND traits.parent_id IS NOT NULL')

    # Metadata FIRST, because some of it moves to the traits.
    CSV.open(meta_file, 'ab') do |csv|
      @process.info("Adding #{@traits.count} traits...")
      add_trait_meta_to_csv(@traits, csv)
      Admin.maintain_db_connection(@process)
      @process.info("Adding #{@assocs.count} assocs...")
      add_trait_meta_to_csv(@assocs, csv)
      add_meta_to_csv(external_trait_metas, csv)
    end

    CSV.open(@trait_filename, 'ab') do |csv|
      @traits.values.each do |trait|
        csv << TRAIT_HEADS.map { |field| trait.send(field) }
      end
      # Skip associations that don't have BOTH nodes defined (they are meaningless):
      @assocs.values.select { |a| a.node && a.target_node }.each do |assoc|
        csv << TRAIT_HEADS.map { |field| assoc.send(field) }
      end
    end
  end

  def trait_map(node_ids)
    @traits = {}
    count = 0
    size = node_ids.size
    meta_count = 0
    @process.info("Building Traits map for #{size} nodes (this can take a while)...")
    Trait.primary.matched.where(node_id: node_ids)
         .includes(:resource, :references, :meta_traits,
                   children: :references, occurrence: :occurrence_metadata,
                   node: :scientific_name).find_each do |trait|
                     count += 1
                     meta_count += trait.meta_traits.size if trait.meta_traits
                     @process.info("#{count} traits mapped (#{meta_count} meta)...") if (count % 100_000).zero?
                     @traits[trait.id] = trait
                   end
    @process.info("Mapped #{count} traits (#{meta_count} meta) for #{size} nodes.")
  end

  def assoc_map(node_ids)
    @assocs = {}
    count = 0
    meta_count = 0
    @process.info("Building Associations map (this can take a while)...")
    Assoc.where(node_id: node_ids)
         .includes(:references, :meta_assocs,
                   occurrence: :occurrence_metadata,
                   node: :scientific_name, target_node: :scientific_name).find_each do |assoc|
                     count += 1
                     meta_count += assoc.meta_assocs.size if assoc.meta_assocs
                     @process.info("#{count} assocs mapped (#{meta_count} meta)...") if (count % 10_000).zero?
                     @assocs[assoc.id] = assoc
                   end
    @process.info("Done. #{count} assocs mapped (#{meta_count} meta).")
  end

  def start_traits_file(filename, heads)
    return if File.exist?(filename)

    FileUtils.touch(filename)
    File.open(filename, 'w') { |file| file.write(heads.join(',') + "\n") }
    @files[filename] = true
  end

  def add_meta_to_csv(metas, csv, trait = nil)
    count = 0

    if metas.respond_to?(:find_each)
      # For whatever reason, Admin.maintain_db_connection does not work here.
      ActiveRecord::Base.connection.reconnect!
      metas.find_each do |meta|
        count += add_one_meta_to_csv(meta, trait, csv)
        ActiveRecord::Base.connection.reconnect!
      end
    else
      metas.each do |meta|
        count += add_one_meta_to_csv(meta, trait, csv)
      end
    end

    count
  end

  def add_one_meta_to_csv(meta, trait, csv)
    data = build_meta(meta, trait)

    if data
      csv << data
      1
    else
      0
    end
  end
  # traits - hash keyed by id

  def add_trait_meta_to_csv(traits, csv)
    count = 0

    traits.each do |key, trait|
      trait_meta_count = trait.metadata.count
      if trait_meta_count > 20
        @process.info("Trait ##{trait.id} in key #{key} has #{trait_meta_count} metadata... that seems high?")
      end
      count += add_meta_to_csv(trait.metadata, csv, trait)
    end

    @process.info("#{count} metadata added.")
  end

  # in_harvest_trait should always be passed in the case that the trait that meta belongs to belongs to the current harvest. Otherwise, it must be nil.
  #
  # If in_harvest_trait is nil, an error will be raised in the case that
  # 1) meta.parent is nil OR
  # 2) meta's predicate is a member of @moved_meta_map
  def build_meta(meta, in_harvest_trait = nil)
    literal = nil
    predicate = nil

    if meta.is_a?(Reference)
      # TODO: we should probably make this URI configurable:
      predicate = 'http://eol.org/schema/reference/referenceID'
      body = meta.body || ''
      body += " <a href='#{meta.url}'>link</a>" unless meta.url.blank?
      body += " #{meta.doi}" unless meta.doi.blank?
      literal = body
    elsif SKIP_METADATA_PRED_URIS.include?(UrisAreEolTerms.new(meta).uri(:predicate_term_uri)&.downcase)
      # these are written as fields in the traits file, so skip (associations are populated from OccurrenceMetadata in
      # ResourceHarvester#resolve_trait_keys)
      return nil
    elsif (meta_mapping = moved_meta_mapping(meta.predicate_term_uri))
      raise TypeError, "moved meta encountered without an in-harvest trait" if in_harvest_trait.nil?
      value = meta.literal
      value = meta.measurement if meta_mapping[:from] && meta_mapping[:from] == :measurement
      in_harvest_trait.send("#{meta_mapping[:to]}=", value)
      return nil # Don't record this one.
    else
      literal = meta.literal
      predicate = UrisAreEolTerms.new(meta).uri(:predicate_term_uri)
    end

    sex_term = UrisAreEolTerms.new(meta).uri(:sex_term_uri)
    lifestage_term = UrisAreEolTerms.new(meta).uri(:lifestage_term_uri)

    # q.v.: META_HEADS for order, here:
    [
      "#{meta.class.name}-#{meta.id}",
      (in_harvest_trait || meta.parent).eol_pk,
      predicate,
      literal,
      meta.respond_to?(:measurement) ? meta.measurement : nil,
      UrisAreEolTerms.new(meta).uri(:object_term_uri),
      UrisAreEolTerms.new(meta).uri(:units_term_uri),
      sex_term,
      lifestage_term,
      UrisAreEolTerms.new(meta).uri(:statistical_method_term_uri),
      UrisAreEolTerms.new(meta).uri(:source),
      meta.respond_to?(:external_meta?) ? meta.external_meta? : false
    ]
  end

  def moved_meta_mapping(uri)
    @moved_meta_map ||= {
      'http://eol.org/schema/terms/samplesize' => { from: :measurement, to: :sample_size },
      'http://purl.org/dc/terms/bibliographiccitation' => { to: :citation },
      'http://purl.org/dc/terms/source' => { to: :source },
      'http://rs.tdwg.org/dwc/terms/measurementremarks' => { to: :remarks },
      'http://rs.tdwg.org/dwc/terms/measurementmethod' => { to: :method }
    }

    @moved_meta_map[uri.downcase]
  end

  def load_hashes
    new_bcs = new_bib_cits_only
    load_hashes_from_array(new_bcs)
    new_locs = new_locs_only
    load_hashes_from_array(new_locs)
    load_hashes_from_array(@nodes_by_pk.values)
    load_hashes_from_array(@identifiers_by_node_pk.values.flatten)
    load_hashes_from_array(@ancestors_by_node_pk.values.flatten)
    load_hashes_from_array(@sci_names_by_node_pk.values.flatten)
    load_hashes_from_array(@media_by_node_pk.values.flatten)
    load_hashes_from_array(@articles_by_node_pk.values.flatten)
    load_hashes_from_array(@image_info_by_node_pk.values.flatten)
    load_hashes_from_array(@vernaculars_by_node_pk.values.flatten)
    load_hashes_from_array(@references)
    load_hashes_from_array(@attributions)
    load_hashes_from_array(@content_sections)
    new_referents = new_referents_only
    load_hashes_from_array(new_referents)
  end

  def remove_existing_pub_files
    WebDb.types.each do |type|
      remove_file(@resource.publish_table_path(type.pluralize))
    end

    %i[metadata external_metadata].each do |type|
      remove_file(@resource.publish_table_path(type))
    end

    remove_file(@trait_filename)
  end

  def remove_file(filename)
    File.unlink(filename) if File.exist?(filename)
  end

  def new_referents_only
    new_objects_only(@referents, @stored_refs)
  end

  def new_bib_cits_only
    new_objects_only(@bib_cits, @stored_bib_cits)
  end

  def new_locs_only
    new_objects_only(@locs, @stored_locs)
  end

  def new_objects_only(source, stored)
    unstored = []
    source.each do |key, ref|
      unstored << ref unless stored.key?(key)
      stored[key] = true
    end
    unstored
  end

  def count_children
    count = {}
    @nodes_by_pk.each_value do |node|
      next unless node.parent_resource_pk

      count[node.parent_resource_pk] ||= 0
      count[node.parent_resource_pk] += 1
    end
    @nodes_by_pk.each do |pk, node|
      node.children_count = count[pk] || 0
    end
  end

  def load_hashes_from_array(array, options = {})
    return nil if array.blank?

    table = options[:table] || array.first.class.name.split(':').last.underscore.pluralize.sub('web_', '')
    # @process.info("Loading #{array.size} #{table}...")
    write_local_csv(table, array, options)
  end

  def write_local_csv(table, structs, options = {})
    file = @resource.publish_table_path(table)
    FileUtils.touch(file)
    # NOTE: this *appends* to the file.
    CSV.open(file, 'ab', col_sep: "\t") do |csv|
      structs.each do |struct|
        # I hate MySQL serialization. Nulls are stored as \N (literally).
        line = struct.to_a.map { |v| v.nil? ? '\\N' : v }
        # NO ID specified if it's a first-time insert, NOTE that the ID MUST be the first item in the struct/array...
        line.delete_at(struct.members.index(:id)) unless options[:replace]
        csv << line
      end
    end
    @files[file] = true
  end

  def timestamp(model)
    t = Time.now.to_s(:db)
    model.created_at = t
    model.updated_at = t
  end
end
