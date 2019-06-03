# Publish to the website database as quick as you can, please. NOTE: We will NOT publish Terms in this code.
class Publisher
  attr_accessor :resource

  def self.by_resource(resource_in, process, options = {})
    new(options.merge(resource: resource_in, process: process)).by_resource
  end

  def self.first
    publisher = new(resource: Resource.first)
    publisher.by_resource
    publisher
  end

# TODO: Inefficient:
# Reference Load (0.7ms)  SELECT `references`.* FROM `references` INNER JOIN `scientific_names_references` ON `references`.`id` = `scientific_names_references`.`reference_id` WHERE `scientific_names_references`.`scientific_name_id` = 4465
# ScientificName Load (0.8ms)  SELECT  `scientific_names`.* FROM `scientific_names` WHERE `scientific_names`.`id` = 4466 LIMIT 1

  def initialize(options = {})
    @resource = options[:resource]
    @process = options[:process]
    @root_url = Rails.application.secrets.repository['url'] || 'http://eol.org'
    @web_resource_id = nil
    @files = {}
    @nodes = {}
    @pages = {}
    @referents = {} # This will store ALL of the referents (the acutal text), and will persist over batches.
    @stored_refs = {} # This will store ref keys that we're already loaded, so we don't do it twice... [sigh]
    @bib_cits = {} # This will store ALL of the bibliographic_citations (the acutal text), and will persist.
    @stored_bib_cits = {} # This will store bib_cit keys that we're already loaded, so we don't do it twice.
    @locs = {} # This will store ALL of the locations (the acutal values), and will persist.
    @stored_locs = {} # This will store location keys that we're already loaded, so we don't do it twice.
    @limit = 10_000
    @trait_heads = %i[eol_pk page_id scientific_name resource_pk predicate sex lifestage statistical_method source
                      object_page_id target_scientific_name value_uri literal measurement units normal_measurement
                      normal_units_uri]
    @meta_heads = %i[eol_pk trait_eol_pk predicate literal measurement value_uri units sex lifestage
                     statistical_method source]

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
    # : all the other hashes, like links
    @same_sci_name_attributes =
      %i[italicized genus specific_epithet infraspecific_epithet infrageneric_epithet uninomial verbatim
         authorship publication remarks parse_quality year hybrid surrogate virus]
    # TODO: Stylesheet and Javascript. ...We don't need them yet, sooo...
    @same_article_attributes = %i[guid resource_pk source_url name body source_url]
    @same_medium_attributes =
      %i[guid resource_pk source_url name description unmodified_url base_url
         source_page_url rights_statement usage_statement]
    @same_node_attributes = %i[page_id parent_resource_pk in_unmapped_area resource_pk source_url]
    @same_vernacular_attributes = %i[node_resource_pk locality remarks source]
  end

  def by_resource
    @process.run_step('overall_tsv_creation') do
      learn_resource_id
      WebDb.init
      slurp_nodes
    end
    @process.info('Done. Check your files:')
    @files.each_key do |file|
      sizes = `wc -l #{file}`
      size = sizes.strip.split.first.to_i
      @process.info("(#{size} lines) #{file.to_s}")
    end
  end

  def learn_resource_id
    @web_resource_id = WebDb.resource_id(@resource)
  end

  def slurp_nodes
    testing = false
    # TODO: add relationships for links
    # TODO: ensure that all of the associations are only pulling in published results. :S
    @nodes = @resource.nodes.published
                      .includes(:identifiers, :node_ancestors, :references,
                                vernaculars: [:language], scientific_names: [:dataset, :references],
                                media: %i[node license language references bibliographic_citation location] <<
                                  { content_attributions: :attribution },
                                articles: %i[node license language references bibliographic_citation location
                                             articles_sections] <<
                                  { content_attributions: :attribution })
    if testing
      nodes = @nodes.limit(100)
      nodes_to_hashes(nodes)
      build_traits(nodes)
    else
      remove_existing_pub_files
      @process.in_batches(batch_size: @limit) do |nodes|
        reset_vars
        nodes_to_hashes(nodes) # This takes a about 75 seconds for a batch of 10K
        count_children # super-fast (about a 20th of a second)
        load_hashes # A few seconds
        build_traits(nodes)
      end
    end
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
      # TODO: links
    end
  end

  def node_to_struct(node)
    web_node = Struct::WebNode.new
    copy_fields(@same_node_attributes, node, web_node)
    web_node.resource_id = @web_resource_id
    web_node.parent_id = node.parent_id # NOTE this is a HARV DB ID. We need to update it.
    web_node.harv_db_id = node.id
    web_node.canonical_form = clean_values(node.safe_canonical)
    web_node.scientific_name = clean_values(node.safe_scientific)
    web_node.has_breadcrumb = clean_values(!node.no_landmark?)
    web_node.rank_id = WebDb.rank(node.rank, @process)
    web_node.is_hidden = 0
    web_node.created_at = Time.now.to_s(:db)
    web_node.updated_at = Time.now.to_s(:db)
    web_node.landmark = Node.landmarks[node.landmark] # NOTE: we are RELYING on the enum being the same, here!
    @nodes_by_pk[node.resource_pk] = web_node
    add_refs(node)
  end

  def copy_fields(fields, source, dest)
    fields.each do |field|
      val = source.attributes.key?(field) ? source[field] : source.send(field)
      dest[field] = clean_values(val)
    end
  end

  def add_refs(object)
    object.references.each do |ref|
      next if @referents.key?(ref.id)
      t = Time.now.to_s(:db)
      referent = Struct::WebReferent.new
      referent.body = clean_values(ref.body)
      referent.created_at = t
      referent.updated_at = t
      referent.resource_id = @web_resource_id
      referent.harv_db_id = ref.id
      @referents[ref.id] = referent
      reference = Struct::WebReference.new
      reference.parent_type = object.class.name
      reference.parent_id = object.id # NOTE: this is a HARV DB ID and should be replaced later.
      reference.resource_id = @web_resource_id
      reference.referent_id = ref.id # NOTE: this is also a harv ID, and will need to be replaced.
      @references << reference
    end
  end

  def add_attributions(object)
    object.content_attributions.each do |content_attribution|
      next unless content_attribution.attribution
      t = Time.now.to_s(:db)
      attribution = Struct::WebAttribution.new
      attribution.value = clean_values(content_attribution.attribution.body)
      attribution.created_at = t
      attribution.updated_at = t
      attribution.resource_id = @web_resource_id
      attribution.resource_pk = content_attribution.attribution.resource_pk
      attribution.content_resource_fk = content_attribution.content_resource_fk
      attribution.content_type = content_attribution.content_type
      attribution.content_id = content_attribution.content_id # NOTE this is the HARVEST DB ID. It will be replaced.
      attribution.role_id = WebDb.role(content_attribution.attribution.role, @process)
      attribution.url = content_attribution.attribution.sanitize_url
      @attributions << attribution
    end
  end

  def add_sections(object, type)
    object.articles_sections.each do |articles_section|
      section = Struct::WebContentSection.new
      section.resource_id = @web_resource_id
      section.content_id = object.id # NOTE this is the HARVEST DB ID. It will be replaced.
      section.content_type = type
      section.section_id = articles_section.section_id # WE ASSUME THE IDs ARE THE SAME! (q.v.: DefaultSections)
      @content_sections << section
    end
  end

  def add_bib_cit(object, citation)
    return if citation.nil?
    # NOTE: THIS ID IS WRONG! This is the *harv_db* ID. We're going to update it later, we're using this as a bridge.
    object.bibliographic_citation_id = citation.id
    return if @bib_cits.key?(citation.id)
    t = Time.now.to_s(:db)
    bc = Struct::WebBibliographicCitation.new
    bc.body = clean_values(citation.body)
    bc.created_at = t
    bc.updated_at = t
    bc.harv_db_id = citation.id
    bc.resource_id = @web_resource_id
    @bib_cits[citation.id] = bc
  end

  def add_loc(object, loc)
    return if loc.nil?
    # NOTE: THIS ID IS WRONG! This is the *harv_db* ID. We're going to update it later, we're using this as a bridge.
    object.location_id = loc.id
    return if @locs.key?(loc.id)
    literal = "#{loc.lat_literal} #{loc.long_literal} #{loc.alt_literal} #{loc.locality}"
    loc_struct = Struct::WebLocation.new
    loc_struct.location = literal
    loc_struct.longitude = loc.long
    loc_struct.latitude = loc.lat
    loc_struct.altitude = loc.alt
    loc_struct.spatial_location = loc.locality
    loc_struct.resource_id = @web_resource_id
    @locs[loc.id] = loc_struct
  end

  def clean_values(src)
    val = src.dup
    val.gsub!("\t", '&nbsp;') if val.respond_to?(:gsub!) # Sorry, no tabs allowed.
    val = 1 if val.class == TrueClass
    val = 0 if val.class == FalseClass
    val
  end

  def build_page(node)
    if @pages.key?(node.page_id)
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
      # TODO: add counts for links, maps
    else
      @pages[node.page_id] = Struct::WebPage.new
      @pages[node.page_id].id = node.page_id
      t = Time.now.to_s(:db)
      @pages[node.page_id].created_at = t
      @pages[node.page_id].updated_at = t
      @pages[node.page_id].articles_count = node.articles.size
      @pages[node.page_id].nodes_count = 1 # This one, silly!
      @pages[node.page_id].vernaculars_count = node.vernaculars.size
      @pages[node.page_id].scientific_names_count = node.scientific_names.size
      @pages[node.page_id].articles_count = node.articles.size
      @pages[node.page_id].referents_count = node.references.size
      # TODO: all of these 0s should be populated, once we have the associations included:
      @pages[node.page_id].links_count = 0 # TODO
      @pages[node.page_id].maps_count = 0 # TODO
      # These are NOT used by our code, but are required by the database (and thus we avoid inserting nulls):
      @pages[node.page_id].page_contents_count = 0
      @pages[node.page_id].species_count = 0
      @pages[node.page_id].is_extinct = 0
      @pages[node.page_id].is_marine = 0
      @pages[node.page_id].has_checked_extinct = 0
      @pages[node.page_id].has_checked_marine = 0
    end
  end

  def build_identifiers(node)
    node.identifiers.each do |ider|
      @identifiers_by_node_pk[node.resource_pk] ||= []
      web_id = Struct::WebIdentifier.new
      web_id.resource_id = @web_resource_id
      web_id.harv_db_id = ider.id
      web_id.node_resource_pk = node.resource_pk
      web_id.node_id = ider.node_id # NOTE: this is a HARV DB ID. We will convert it later.
      web_id.identifier = ider.identifier
      @identifiers_by_node_pk[node.resource_pk] << web_id
    end
  end

  def build_ancestors(node)
    node.node_ancestors.each do |nodan|
      @ancestors_by_node_pk[node.resource_pk] ||= []
      anc = Struct::WebNodeAncestor.new
      anc.resource_id = @web_resource_id
      anc.harv_db_id = nodan.id # TODO: I'm not sure this is required?
      anc.node_id = nodan.node_id # NOTE: this is a HARV DB ID. We will convert it later.
      anc.ancestor_id = nodan.ancestor_id # NOTE: this is a HARV DB ID. We will convert it later.
      anc.node_resource_pk = node.resource_pk
      anc.ancestor_resource_pk = nodan.ancestor_fk
      anc.depth = nodan.depth
      @ancestors_by_node_pk[node.resource_pk] << anc
    end
  end

  def build_scientific_names(node)
    node.scientific_names.each do |name_model|
      @sci_names_by_node_pk[node.resource_pk] ||= []
      web_sci_name = build_scientific_name(node, name_model)
      @sci_names_by_node_pk[node.resource_pk] << web_sci_name
      add_refs(name_model)
    end
  end

  def build_scientific_name(node, name_model)
    name_struct = Struct::WebScientificName.new
    name_struct.node_id = node.id # NOTE: this is a HARV DB ID. We will convert it later.
    name_struct.page_id = node.page_id
    name_struct.harv_db_id = name_model.id
    name_struct.canonical_form = clean_values(name_model.canonical_italicized)
    name_struct.taxonomic_status_id = WebDb.taxonomic_status(name_model.taxonomic_status.try(:downcase), @process)
    name_struct.is_preferred = clean_values(node.scientific_name_id == name_model.id)
    name_struct.created_at = Time.now.to_s(:db)
    name_struct.updated_at = Time.now.to_s(:db)
    name_struct.resource_id = @web_resource_id
    name_struct.node_resource_pk = clean_values(node.resource_pk)
    # name_struct.source_reference = name_model. ...errr.... TODO: This is intended to move off of the node. Put it
    # here!
    name_struct.attribution = clean_values(name_model.attribution_html)
    name_struct.attribution = clean_values(name_model.dataset_name)
    name_struct.attribution = clean_values(name_model.name_according_to)
    copy_fields(@same_sci_name_attributes, name_model, name_struct)
    name_struct
  end

  def build_media(node)
    node.media.each do |medium|
      @media_by_node_pk[node.resource_pk] ||= []
      web_medium = build_medium(node, medium)
      @media_by_node_pk[node.resource_pk] << web_medium
      add_refs(medium)
      add_attributions(medium)
      add_bib_cit(web_medium, medium.bibliographic_citation)
      add_loc(web_medium, medium.location)
      if medium.w && medium.h
        @image_info_by_node_pk[node.resource_pk] ||= []
        @image_info_by_node_pk[node.resource_pk] << build_image_info(medium)
      end
    end
  end

  def build_articles(node)
    node.articles.each do |article|
      @articles_by_node_pk[node.resource_pk] ||= []
      web_article = build_article(node, article)
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
      @vernaculars_by_node_pk[node.resource_pk] << build_vernacular(node, vernacular)
    end
  end

  def build_image_info(medium)
    ii = Struct::WebImageInfo.new
    ii.resource_id = @web_resource_id
    ii.medium_id = medium.id # NOTE this is a HARV DB ID, and needs to be replaced.
    ii.original_size = "#{medium.w}x#{medium.h}" if medium.w && medium.h
    unless medium.sizes.blank?
      # e.g.: {"88x88"=>"88x88", "98x68"=>"98x65", "580x360"=>"540x360", "130x130"=>"130x130", "260x190"=>"260x173"}
      sizes = JSON.parse(medium.sizes)
      ii.large_size = sizes['580x360']
      ii.medium_size = sizes['260x190']
      ii.small_size = sizes['98x68']
    end
    ii.crop_x = medium.crop_x_pct
    ii.crop_y = medium.crop_y_pct
    ii.crop_w = medium.crop_w_pct
    t = Time.now.to_s(:db)
    ii.created_at = t
    ii.updated_at = t
    ii.resource_pk = medium.resource_pk
    # ii.harv_db_id = medium.id # TODO: this is not really needed, as II isn't a harv DB model. :|
    ii
  end

  def build_medium(node, medium)
    web_medium = Struct::WebMedium.new
    web_medium.page_id = node.page_id
    web_medium.harv_db_id = medium.id
    web_medium.subclass = Medium.subclasses[medium.subclass]
    web_medium.format = Medium.formats[medium.format]
    web_medium.owner = medium.owner
    # TODO: ImageInfo from medium.sizes
    copy_fields(@same_medium_attributes, medium, web_medium)
    web_medium.created_at = Time.now.to_s(:db)
    web_medium.updated_at = Time.now.to_s(:db)
    web_medium.resource_id = @web_resource_id
    web_medium.name = clean_values(medium.name_verbatim) if medium.name.blank?
    web_medium.description = clean_values(medium.description_verbatim) if medium.description.blank?
    web_medium.base_url = if medium.base_url.nil? # The image has not been downloaded.
                            "#{@root_url}/#{medium.default_base_url}"
                          else
                            # It *has* been downloaded, but still lacks the root URL, so we add that:
                            "#{@root_url}/#{medium.base_url}"
                          end
    web_medium.license_id = WebDb.license(medium.license&.source_url, @process)
    web_medium.language_id = WebDb.language(medium.language, @process)
    web_medium
  end

  # NOTE: articles will not be visible until the website runs the same code as for build_medium (q.v.)
  def build_article(node, article)
    web_article = Struct::WebArticle.new
    web_article.page_id = node.page_id
    web_article.harv_db_id = article.id
    web_article.owner = article.owner
    copy_fields(@same_article_attributes, article, web_article)
    web_article.created_at = Time.now.to_s(:db)
    web_article.updated_at = Time.now.to_s(:db)
    web_article.resource_id = @web_resource_id
    web_article.license_id = WebDb.license(article.license&.source_url, @process)
    web_article.language_id = WebDb.language(article.language, @process)
    web_article
  end

  def build_traits(nodes)
    return unless Trait.where(node_id: nodes.map(&:id)).any? ||
                  Assoc.where(node_id: nodes.map(&:id)).any?
    @process.info("#{Trait.where(node_id: nodes.map(&:id)).count} Traits (unfiltered)...")
    # NOTE: this query is MOSTLY copied (but tweaked) from TraitsController.
    simple_meta_fields = %i[predicate_term object_term]
    meta_fields = simple_meta_fields + %i[units_term statistical_method_term]
    assoc_meta_fields = simple_meta_fields + %i[units_term]
    property_fields = meta_fields + %i[sex_term lifestage_term references]
    traits =
      Trait.primary.published.matched.where(node_id: nodes.map(&:id))
           .includes(property_fields,
                     children: meta_fields,
                     occurrence: { occurrence_metadata: meta_fields },
                     node: :scientific_name,
                     meta_traits: meta_fields)
    @process.info("#{traits.size} Traits (filtered)...")
    assocs =
      Assoc.published.where(node_id: nodes.map(&:id))
           .includes(:predicate_term, :sex_term, :lifestage_term, :references,
                     occurrence: { occurrence_metadata: meta_fields },
                     node: :scientific_name, target_node: :scientific_name,
                     meta_assocs: assoc_meta_fields)

    @process.info("#{assocs.size} Associations (filtered)...")
    filename = @resource.publish_table_path('traits')
    meta_file = @resource.publish_table_path('metadata')
    start_traits_file(filename, @trait_heads)
    start_traits_file(meta_file, @meta_heads)
    CSV.open(filename, 'ab') do |csv|
      traits.each do |trait|
        csv << @trait_heads.map { |field| trait.send(field) }
      end
      # Skip associations that don't have BOTH nodes defined (they are meaningless):
      assocs.select { |a| a.node && a.target_node }.each do |assoc|
        csv << @trait_heads.map { |field| assoc.send(field) }
      end
    end
    CSV.open(meta_file, 'ab') do |csv|
      add_meta_to_csv(traits, csv)
      add_meta_to_csv(assocs, csv)
    end
  end

  def start_traits_file(filename, heads)
    unless File.exist?(filename)
      FileUtils.touch(filename)
      File.open(filename, 'w') { |file| file.write(heads.join(',') + "\n") }
      @files[filename] = true
    end
  end

  def add_meta_to_csv(traits, csv)
    count = 0
    traits.each do |trait|
      trait.metadata.each do |meta|
        count += 1
        csv << build_meta(meta, trait)
      end
    end
    @process.info("#{count} metadata added.")
  end

  def build_meta(meta, trait)
    predicate = nil
    literal = nil
    if meta.is_a?(Reference)
      # TODO: we should probably make this URI configurable:
      predicate = 'http://eol.org/schema/reference/referenceID'
      body = meta.body || ''
      body += " <a href='#{meta.url}'>link</a>" unless meta.url.blank?
      body += " #{meta.doi}" unless meta.doi.blank?
      literal = body
    else
      predicate = meta.predicate_term&.uri
      literal = meta.literal
    end
    # q.v.: @meta_heads for order, here:
    [ "#{meta.class.name}-#{meta.id}",
      trait.eol_pk,
      predicate,
      literal,
      meta.respond_to?(:measurement) ? meta.measurement : nil,
      meta.respond_to?(:object_term) ? meta.object_term&.uri : nil,
      meta.respond_to?(:units_term) ? meta.units_term&.uri : nil,
      meta.respond_to?(:sex_term) ? meta.sex_term&.uri : nil,
      meta.respond_to?(:lifestage_term) ? meta.lifestage_term&.uri : nil,
      meta.respond_to?(:statistical_method_term) ? meta.statistical_method_term&.uri : nil,
      meta.respond_to?(:source) ? meta.source : nil
    ]
  end

  # TODO: move this method up.
  # NOTE: vernaculars will not be preferred until the website runs
  # Vernacular.joins(:page).where(['pages.vernaculars_count = 1 AND vernaculars.is_preferred_by_resource = ? '\
  #   'AND vernaculars.resource_id = ?', true, @resource.id]).update_all(is_preferred: true)
  def build_vernacular(node, vernacular)
    web_vern = Struct::WebVernacular.new
    web_vern.node_id = node.id # NOTE: this is a HARV DB ID. We will convert it later.
    web_vern.page_id = node.page_id
    web_vern.harv_db_id = vernacular.id
    web_vern.resource_id = @web_resource_id
    web_vern.language_id = WebDb.language(vernacular.language, @process)
    web_vern.created_at = Time.now.to_s(:db)
    web_vern.updated_at = Time.now.to_s(:db)
    web_vern.is_preferred = 0 # This will be fixed by the code mentioned above, run on the website.
    web_vern.trust = 0
    web_vern.is_preferred_by_resource = clean_values(vernacular.is_preferred || false)
    web_vern.string = clean_values(vernacular.verbatim)
    copy_fields(@same_vernacular_attributes, vernacular, web_vern)
    web_vern
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
      file = @resource.publish_table_path(type.pluralize)
      File.unlink(file) if File.exist?(file)
    end
    %i[traits metadata].each do |type|
      file = @resource.publish_table_path(type)
      File.unlink(file) if File.exist?(file)
    end
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
end
