# Publish to the website database as quick as you can, please. NOTE: We will NOT publish Terms or traits in this code.
# We'll keep that a pull, since this codebase doesn't understand TraitBank/neo4j.
class Publisher
  attr_accessor :resource, :nodes, :nodes_by_pk, :identifiers_by_node_pk

  def self.by_resource(resource_in)
    new(resource: resource_in).by_resource
  end

  def self.first
    publisher = new(resource: Resource.first)
    publisher.by_resource
    publisher
  end

  def initialize(options = {})
    @resource = options[:resource]
    @logger = @resource.harvests.completed.last
    @root_url = Rails.application.secrets.repository['url'] || 'http://eol.org'
    @web_resource_id = nil
    reset_nodes
    @nodes_by_pk = {}
    @pages = {}
    @identifiers_by_node_pk = {}
    @ancestors_by_node_pk = {}
    @sci_names_by_node_pk = {}
    @media_by_node_pk = {}
    @vernaculars_by_node_pk = {}
    # TODO: all the other hashes, like refs, links, articles, image_info
    @taxonomic_statuses = {}
    @ranks = {}
    @licenses = {}
    @languages = {}
    @types = %w[node identifier scientific_name node_ancestor vernacular medium image_info page_content]
    @same_sci_name_attributes =
      %i[italicized genus specific_epithet infraspecific_epithet infrageneric_epithet uninomial verbatim
         authorship publication remarks parse_quality year hybrid surrogate virus]
    @same_medium_attributes =
      %i[guid resource_pk owner source_url name description unmodified_url base_url
         source_page_url rights_statement usage_statement location_id bibliographic_citation_id]
    @same_node_attributes = %i[page_id parent_resource_pk in_unmapped_area resource_pk source_url]
    @same_vernacular_attributes = %i[node_resource_pk locality remarks source]
  end

  def reset_nodes
    @nodes = {}
  end

  def by_resource
    build_structs
    build_ranks
    learn_resource_id
    measure_time('Slurped all data') { slurp_nodes }
    reset_nodes # We no longer need it, free up the memory.
    measure_time('Counted all children') { count_children }
    measure_time('Removed old data') { remove_old_data }
    measure_time('Loaded new data') { load_hashes }
    # TODO: Create missing pages! Yuck.
    # TODO: Throw warnings for any objects that ended up with node_id = 0 (sci names, vernaculars at least...) ...maybe
    # we shouldn't even include them in the DB.
  end

  def measure_time(what, &_block)
    t = Time.now
    yield
    puts "#{what} in #{Time.delta_s(t)}"
  end

  def build_structs
    (@types + ['page']).each do |type|
      attributes = WebDb.columns(type.pluralize)
      Struct.new("Web#{type.camelize}", *attributes)
    end
  end

  def build_ranks
    @ranks = WebDb.map_ids('ranks', 'name')
  end

  def learn_resource_id
    @web_resource_id = WebDb.resource_id(@resource)
  end

  def slurp_nodes
    testing = false
    # TODO: add relationships for refs, articles, links, image_info.
    # TODO: ensure that all of the associations are only pulling in published results. :S
    @nodes = @resource.nodes.published
                      .includes(:identifiers, :node_ancestors, :vernaculars,
                                scientific_names: [:dataset], media: %i[node license language])
    if testing
      nodes_to_hashes(@nodes.limit(100))
    else
      @nodes.find_in_batches(batch_size: 10_000) { |nodes| nodes_to_hashes(nodes) }
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
      build_vernaculars(node)
      # TODO: refs, articles, links, image_info.
      # NOTE: We will NOT import Terms or traits in this code. We'll keep that a pull, since this codebase doesn't
      # understand TraitBank/neo4j.
    end
  end

  def node_to_struct(node)
    web_node = Struct::WebNode.new
    copy_fields(@same_node_attributes, node, web_node)
    web_node.resource_id = @web_resource_id
    web_node.canonical_form = clean_values(node.safe_canonical)
    web_node.scientific_name = clean_values(node.safe_scientific)
    web_node.has_breadcrumb = clean_values(!node.no_landmark?)
    web_node.rank_id = get_rank(node.rank)
    web_node.is_hidden = 0
    web_node.created_at = now
    web_node.updated_at = now
    web_node.landmark = Node.landmarks[node.landmark] # NOTE: we are RELYING on the enum being the same, here!
    @nodes_by_pk[node.resource_pk] = web_node
  end

  def copy_fields(fields, source, dest)
    fields.each do |field|
      val = source.attributes.key?(field) ? source[field] : source.send(field)
      dest[field] = clean_values(val)
    end
  end

  def now
    Time.now.to_s(:db)
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
      @pages[node.page_id].nodes_count += 1
    else
      @pages[node.page_id] = Struct::WebPage.new
      t = now
      @pages[node.page_id].created_at = t
      @pages[node.page_id].updated_at = t
      @pages[node.page_id].media_count = 0
      @pages[node.page_id].articles_count = 0
      @pages[node.page_id].links_count = 0
      @pages[node.page_id].maps_count = 0
      @pages[node.page_id].nodes_count = 1 # This one, silly!
      @pages[node.page_id].vernaculars_count = 0
      @pages[node.page_id].scientific_names_count = 0
      @pages[node.page_id].referents_count = 0
    end
  end

  def build_identifiers(node)
    node.identifiers.each do |ider|
      @identifiers_by_node_pk[node.resource_pk] ||= []
      web_id = Struct::WebIdentifier.new
      web_id.resource_id = @web_resource_id
      web_id.node_resource_pk = node.resource_pk
      web_id.identifier = ider.identifier
      @identifiers_by_node_pk[node.resource_pk] << web_id
    end
  end

  def build_ancestors(node)
    node.node_ancestors.each do |nodan|
      @ancestors_by_node_pk[node.resource_pk] ||= []
      anc = Struct::WebNodeAncestor.new
      anc.resource_id = @web_resource_id
      anc.node_resource_pk = node.resource_pk
      anc.ancestor_resource_pk = nodan.ancestor_fk
      anc.depth = nodan.depth
      @ancestors_by_node_pk[node.resource_pk] << anc
    end
  end

  def build_scientific_names(node)
    node.scientific_names.each do |name_model|
      @sci_names_by_node_pk[node.resource_pk] ||= []
      @sci_names_by_node_pk[node.resource_pk] << build_scientific_name(node, name_model)
    end
  end

  def build_scientific_name(node, name_model)
    name_struct = Struct::WebScientificName.new
    name_struct.node_id = 0 # We *should* loop back for this later.
    name_struct.page_id = node.page_id
    name_struct.canonical_form = clean_values(name_model.canonical_italicized)
    name_struct.taxonomic_status_id = clean_values(get_taxonomic_status(name_model.taxonomic_status.try(:downcase)))
    name_struct.is_preferred = clean_values(node.scientific_name_id == name_model.id)
    name_struct.created_at = now
    name_struct.updated_at = now
    name_struct.resource_id = @web_resource_id
    name_struct.node_resource_pk = clean_values(node.resource_pk)
    # name_struct.source_reference = name_model. ...errr.... TODO: This is intended to move off of the node. Put it
    # here!
    name_struct.attribution = clean_values(name_model.attribution_html)
    copy_fields(@same_sci_name_attributes, name_model, name_struct)
    name_struct
  end

  def build_media(node)
    node.media.each do |medium|
      @media_by_node_pk[node.resource_pk] ||= []
      @media_by_node_pk[node.resource_pk] << build_medium(node, medium)
    end
  end

  def build_vernaculars(node)
    node.vernaculars.each do |vernacular|
      @vernaculars_by_node_pk[node.resource_pk] ||= []
      @vernaculars_by_node_pk[node.resource_pk] << build_vernacular(node, vernacular)
    end
  end

  # NOTE: media will not be visible until the website runs
  # MediaContentCreator.by_resource(@resource, Publishing::PubLog.new(@resource))
  def build_medium(node, medium)
    web_medium = Struct::WebMedium.new
    web_medium.page_id = node.page_id
    web_medium.subclass = Medium.subclasses[medium.subclass]
    web_medium.format = Medium.formats[medium.format]
    # TODO: ImageInfo from medium.sizes
    copy_fields(@same_medium_attributes, medium, web_medium)
    web_medium.created_at = now
    web_medium.updated_at = now
    web_medium.resource_id = @web_resource_id
    web_medium.name = clean_values(medium.name_verbatim) if medium.name.blank?
    web_medium.description = clean_values(medium.description_verbatim) if medium.description.blank?
    if medium.base_url.nil? # The image has not been downloaded.
      web_medium.base_url = "#{@root_url}/#{medium.default_base_url}"
    end
    web_medium.license_id = get_license(medium.license.try(:source_url))
    web_medium.language_id = get_language(medium.language)
    web_medium
  end

  # NOTE: vernaculars will not be preferred until the website runs
  # Vernacular.joins(:page).where(['pages.vernaculars_count = 1 AND vernaculars.is_preferred_by_resource = ? '\
  #   'AND vernaculars.resource_id = ?', true, @resource.id]).update_all(is_preferred: true)
  def build_vernacular(node, vernacular)
    web_vern = Struct::WebVernacular.new
    web_vern.page_id = node.page_id
    web_vern.language_id = get_language(vernacular.language)
    web_vern.is_preferred_by_resource = get_language(vernacular.is_preferred)
    web_vern.string = get_language(vernacular.verbatim)
    copy_fields(@same_vernacular_attributes, vernacular, web_vern)
  end

  def remove_old_data
    @types.each do |type|
      table = type.pluralize
      WebDb.remove_resource_data(table, @resource.id)
    end
  end

  def load_hashes
    load_hashes_from_array(@nodes_by_pk.values)
    learn_node_ids
    propagate_node_ids
    # TODO: other relationships, like refs, articles, links, image_info.
    load_hashes_from_array(@nodes_by_pk.values, replace: true)
    load_hashes_from_array(@ancestors_by_node_pk.values.flatten)
    load_hashes_from_array(@sci_names_by_node_pk.values.flatten)
    load_hashes_from_array(@media_by_node_pk.values.flatten)
    load_hashes_from_array(@vernaculars_by_node_pk.values.flatten)
    load_pages
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

  def learn_node_ids
    id_map = WebDb.map_ids('nodes', 'resource_pk')
    @nodes_by_pk.each_value do |node|
      node.id = id_map[node.resource_pk]
    end
  end

  def propagate_node_ids
    @nodes_by_pk.each do |node_pk, node|
      # TODO: ...many of the relationships on the other models, like refs, articles, links, image_info.
      unless @nodes_by_pk.key?(node.parent_resource_pk)
        puts "WARNING: missing parent with res_pk: #{node.parent_resource_pk} ... I HOPE YOU ARE JUST TESTING!"
        next
      end
      node.parent_id = @nodes_by_pk[node.parent_resource_pk].id
      @ancestors_by_node_pk[node_pk].compact.each do |ancestor|
        ancestor.node_id = node.id
        unless @nodes_by_pk.key?(ancestor.ancestor_resource_pk)
          puts "WARNING: missing ancestor with res_pk: #{ancestor.ancestor_resource_pk} ...I HOPE YOU ARE JUST TESTING!"
          next
        end
        ancestor.ancestor_id = @nodes_by_pk[ancestor.ancestor_resource_pk].id
      end
      # Simpler propagation of node ID only:
      set_node_ids(@sci_names_by_node_pk, node_pk, node.id)
      set_node_ids(@media_by_node_pk, node_pk, node.id)
      set_node_ids(@vernaculars_by_node_pk, node_pk, node.id)
      update_page(node)
    end
  end

  def set_node_ids(hash, node_pk, node_id)
    hash[node_pk].compact.each do |struct|
      struct.node_id = node_id
    end
  end

  def update_page(node)
    @pages[node.page_id].native_node_id = node.id # NOTE this does NOT get used if the page already exists!
    @pages[node.page_id].media_count += node.media.size
    @pages[node.page_id].articles_count += node.articles.size
    # TODO: all of these:
    # @pages[node.page_id].links_count += node.links.size
    # @pages[node.page_id].maps_count += node.maps.size
    @pages[node.page_id].vernaculars_count += node.vernaculars.size
    @pages[node.page_id].scientific_names_count += node.scientific_names.size
    # @pages[node.page_id].referents_count += node.referents.size
  end

  def load_pages
    cols = WebDb.page_columns_to_update
    existing_pages = update_page_counts(WebDb.pages_to_update(@pages.keys), cols)
    load_from_array(existing_pages, 'pages', cols, replace: true)
    new_page_ids = @pages.keys - (existing_pages.map { |p| p[0] })
    load_hashes_from_array(new_page_ids.map { |id| @pages[id] })
  end

  def update_page_counts(pages, cols)
    col = {}
    cols.each_with_index { |name, i| col[name] = i }
    pages.each do |page|
      id = page[0] # Yes, I "should" do this "properly" with col['id'], but it MUST be the 0th column, so save the work.
      page[col['updated_at']] = @pages[id].updated_at.to_s(:db)
      page[col['media_count']] += @pages[id].media_count
      # TODO: these...
      # page[col['articles_count']] += @pages[id].articles_count
      # page[col['links_count']] += @pages[id].links_count
      # page[col['maps_count']] += @pages[id].maps_count
      page[col['nodes_count']] += @pages[id].nodes_count
      page[col['vernaculars_count']] += @pages[id].vernaculars_count
      page[col['scientific_names_count']] += @pages[id].scientific_names_count
    end
  end

  def load_hashes_from_array(array, options = {})
    return nil if array.empty?
    table = array.first.class.name.split(':').last.underscore.pluralize.sub('web_', '')
    cols = unless options[:replace]
             c = array.first.members
             c.delete(:id)
             c
           end
    load_from_array(array, table, cols, options)
  end

  def load_from_array(array, table, cols, options = {})
    return nil if array.empty?
    t = Time.now
    file = Tempfile.new("rails.eol_website.#{table}")
    begin
      write_local_csv(file, array, options)
      puts "Wrote to #{file.path} in #{Time.delta_s(t)}"
      WebDb.import_csv(file.path, table, cols)
    ensure
      File.unlink(file)
    end
  end

  def write_local_csv(file, structs, options = {})
    CSV.open(file, 'wb', col_sep: "\t") do |csv|
      structs.each do |struct|
        # I hate MySQL serialization. Nulls are stored as \N (literally).
        line = struct.to_a.map { |v| v.nil? ? '\\N' : v }
        # NO ID specified if it's a first-time insert, NOTE that the ID MUST be the first item in the struct/array...
        line.delete_at(0) unless options[:replace]
        csv << line
      end
    end
  end

  def get_rank(full_rank)
    return nil if full_rank.nil?
    rank = full_rank.downcase
    return nil if rank.blank?
    return @ranks[rank] if @ranks.key?(rank)
    log_warn("Encountered new rank, please assign it to a preferred rank: #{rank}")
    @ranks[rank] = WebDb.raw_create_rank(rank) # NOTE this is NOT #raw_create, q.v..
  end

  def get_license(url)
    return nil if url.nil?
    license = url.downcase
    return nil if license.blank?
    return @licenses[license] if @licenses.key?(license)
    log_warn("Encountered new license, please find a logo URL and give it a name: #{url}")
    # NOTE: passing int case-sensitive name... and a bogus name.
    @licenses[license] = WebDb.raw_create('licenses', source_url: url, name: url, created_at: now, updated_at: now)
  end

  def get_language(language)
    return nil if language.blank?
    return @languages[language.id] if @languages.key?(language.id)
    log_warn("Encountered new language, please assign it to a language group and give it a name: #{language}")
    @languages[language.id] = WebDb.raw_create('languages', code: language.code, group: language.group_code)
  end

  def get_taxonomic_status(full_name)
    return nil if full_name.nil?
    name = full_name.downcase
    return nil if name.blank?
    return @taxonomic_statuses[name] if @taxonomic_statuses.key?(name)
    log_warn("Encountered new taxonomic status, please assign set its alternative/preferred/problematic/megeable: #{name}")
    @taxonomic_statuses[name] = WebDb.raw_create('taxonomic_statuses', name: name)
  end

  def log_warn(message)
    @logger.log(message, cat: :warns)
  end
end
