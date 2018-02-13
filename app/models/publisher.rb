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
    @has_media = false
    @nodes_by_pk = {}
    @pages = {}
    @identifiers_by_node_pk = {}
    @ancestors_by_node_pk = {}
    @sci_names_by_node_pk = {}
    @media_by_node_pk = {}
    @vernaculars_by_node_pk = {}
    @articles_by_node_pk = {}
    # Oh boy. Here we go...
    @refs_by_node_pk = {}
    @refs_by_article_pk = {}
    @refs_by_medium_pk = {}
    @bit_cits_by_article_pk = {}
    @bit_cits_by_medium_pk = {}
    @locs_by_article_pk = {}
    @locs_by_medium_pk = {}
    # TODO: all the other hashes, like links, image_info
    @taxonomic_statuses = {}
    @ranks = {}
    @licenses = {}
    @languages = {}
    @types = %w[node identifier scientific_name node_ancestor vernacular medium image_info page_content]
    @same_sci_name_attributes =
      %i[italicized genus specific_epithet infraspecific_epithet infrageneric_epithet uninomial verbatim
         authorship publication remarks parse_quality year hybrid surrogate virus]
    # TODO: location (on articles and media); bibliographic_citation (on Articles and Media)
    # TODO: Stylesheet and Javascript. ...We don't need them yet, sooo...
    @same_article_attributes = %i[guid resource_pk owner source_url name body source_url]
    @same_medium_attributes =
      %i[guid resource_pk owner source_url name description unmodified_url base_url
         source_page_url rights_statement usage_statement]
    @same_node_attributes = %i[page_id parent_resource_pk in_unmapped_area resource_pk source_url]
    @same_vernacular_attributes = %i[node_resource_pk locality remarks source]
  end

  def now
    Time.now.to_s(:db)
  end

  def reset_nodes
    count = @nodes&.size
    @nodes = {}
    count || 0
  end

  def by_resource
    count = 0
    measure_time('OVERALL PUBLISHING') do
      learn_resource_id
      abort_if_republishing
      build_structs
      build_ranks
      build_languages
      build_licenses
      build_taxonomic_statuses
      measure_time('Slurped all data') { slurp_nodes }
      count = reset_nodes # We no longer need it, free up the memory.
      measure_time('Counted all children') { count_children }
      measure_time('Loaded new data') { load_hashes }
      # TODO: Throw warnings for any objects that ended up with node_id = 0 (sci names, vernaculars at least...)
      # ...maybe we shouldn't even include them in the DB.
    end
    if @has_media
      puts "You MUST run this on the website now:"
      puts "r = Resource.find(#{@web_resource_id}); MediaContentCreator.by_resource(r, Publishing::PubLog.new(r))"
    end
    puts "Done. #{count} nodes published."
  end

  def measure_time(what, &_block)
    t = Time.now
    yield
    log_warn "#{what} in #{Time.delta_s(t)}"
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

  def build_languages
    @languages = WebDb.map_ids('languages', 'code')
  end

  def build_licenses
    @licenses = WebDb.map_ids('licenses', 'source_url')
  end

  def build_taxonomic_statuses
    @taxonomic_statuses = WebDb.map_ids('taxonomic_statuses', 'name')
  end

  def learn_resource_id
    @web_resource_id = WebDb.resource_id(@resource)
  end

  def slurp_nodes
    testing = false
    # TODO: add relationships for links, image_info.
    # TODO: ensure that all of the associations are only pulling in published results. :S
    @nodes = @resource.nodes.published
                      .includes(:identifiers, :node_ancestors, :references,
                                vernaculars: [:language], scientific_names: [:dataset],
                                media: %i[node license language references bibliographic_citation location],
                                articles: %i[node license language references bibliographic_citation location])
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
      build_articles(node)
      # TODO: links, image_info.
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
    add_refs(@refs_by_node_pk, node.resource_pk, node.references)
  end

  def copy_fields(fields, source, dest)
    fields.each do |field|
      val = source.attributes.key?(field) ? source[field] : source.send(field)
      dest[field] = clean_values(val)
    end
  end

  def add_refs(hash, pk, refs)
    refs.each do |ref|
      hash[pk] ||= []
      t = now
      hash[pk] << WebReference.new(body: ref.body, created_at: t, updated_at: t, resource_id: @web_resource_id)
    end
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
      @pages[node.page_id].media_count += node.media.count
      @pages[node.page_id].vernaculars_count += node.vernaculars.count
      @pages[node.page_id].scientific_names_count += node.scientific_names.count
      # TODO: add counts for articles, links, maps, and refs
    else
      @pages[node.page_id] = Struct::WebPage.new
      @pages[node.page_id].id = node.page_id
      t = now
      @pages[node.page_id].created_at = t
      @pages[node.page_id].updated_at = t
      @pages[node.page_id].media_count = node.media.count
      @pages[node.page_id].nodes_count = 1 # This one, silly!
      @pages[node.page_id].vernaculars_count = node.vernaculars.count
      @pages[node.page_id].scientific_names_count = node.scientific_names.count
      # TODO: all of these 0s should be populated, once we have the associations included:
      @pages[node.page_id].articles_count = 0 # TODO
      @pages[node.page_id].links_count = 0 # TODO
      @pages[node.page_id].maps_count = 0 # TODO
      @pages[node.page_id].referents_count = 0 # TODO
      # These are NOT used by our code, but are required by the database (and thus we avoid inserting nulls):
      @pages[node.page_id].page_contents_count = 0
      @pages[node.page_id].data_count = 0
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
      add_refs(@refs_by_sci_name_pk, name_model.resource_pk, name_model.references)
    end
  end

  def build_scientific_name(node, name_model)
    name_struct = Struct::WebScientificName.new
    name_struct.node_id = 0 # We *should* loop back for this later.
    name_struct.page_id = node.page_id
    name_struct.canonical_form = clean_values(name_model.canonical_italicized)
    name_struct.taxonomic_status_id = get_taxonomic_status(name_model.taxonomic_status.try(:downcase))
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
      add_refs(@media_by_node_pk, medium.resource_pk, medium.references)
    end
  end

  def build_articles(node)
    node.media.each do |article|
      @articles_by_node_pk[node.resource_pk] ||= []
      @articles_by_node_pk[node.resource_pk] << build_article(node, article)
      add_refs(@media_by_node_pk, article.resource_pk, article.references)
    end
  end

  def build_vernaculars(node)
    node.vernaculars.each do |vernacular|
      @vernaculars_by_node_pk[node.resource_pk] ||= []
      @vernaculars_by_node_pk[node.resource_pk] << build_vernacular(node, vernacular)
    end
  end

  # TODO: add refs
  def build_medium(node, medium)
    @has_media ||= true
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
    web_medium.license_id = get_license(medium.license&.source_url)
    web_medium.language_id = get_language(medium.language)
    web_medium
  end

  # TODO: add refs
  # NOTE: articles will not be visible until the website runs
  # TODOContentCreator.by_resource(@resource, Publishing::PubLog.new(@resource))
  def build_article(node, article)
    @has_articles ||= true
    web_article = Struct::WebArticle.new
    web_article.page_id = node.page_id
    copy_fields(@same_article_attributes, article, web_article)
    web_article.created_at = now
    web_article.updated_at = now
    web_article.resource_id = @web_resource_id
    web_article.license_id = get_license(article.license&.source_url)
    web_article.language_id = get_language(article.language)
    web_article
  end

  # NOTE: vernaculars will not be preferred until the website runs
  # Vernacular.joins(:page).where(['pages.vernaculars_count = 1 AND vernaculars.is_preferred_by_resource = ? '\
  #   'AND vernaculars.resource_id = ?', true, @resource.id]).update_all(is_preferred: true)
  def build_vernacular(node, vernacular)
    web_vern = Struct::WebVernacular.new
    web_vern.page_id = node.page_id
    web_vern.resource_id = @web_resource_id
    web_vern.language_id = get_language(vernacular.language)
    web_vern.created_at = now
    web_vern.updated_at = now
    web_vern.is_preferred = 0 # This will be fixed by the code mentioned above, run on the website.
    web_vern.trust = 0
    web_vern.is_preferred_by_resource = clean_values(vernacular.is_preferred || false)
    web_vern.string = clean_values(vernacular.verbatim)
    copy_fields(@same_vernacular_attributes, vernacular, web_vern)
    web_vern
  end

  # TODO: We should have some kind of API call to automate this. :|  ...Or should we? Security is challenging.
  def abort_if_republishing
    raise "ERROR: you MUST Resource.find(#{@web_resource_id}).remove_content on the website before running this." if
      WebDb.any_nodes?(@web_resource_id)
  end

  def load_hashes
    load_hashes_from_array(@nodes_by_pk.values)
    learn_node_ids
    propagate_node_ids
    # TODO: other relationships, like refs, links, image_info.
    load_hashes_from_array(@nodes_by_pk.values, replace: true)
    load_hashes_from_array(@ancestors_by_node_pk.values.flatten)
    load_hashes_from_array(@sci_names_by_node_pk.values.flatten)
    load_hashes_from_array(@media_by_node_pk.values.flatten)
    load_hashes_from_array(@articles_by_node_pk.values.flatten)
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
    id_map = WebDb.map_ids('nodes', 'resource_pk', resource_id: @web_resource_id)
    @nodes_by_pk.each_value do |node|
      node.id = id_map[node.resource_pk]
    end
  end

  # NOTE: Articles and Media actually don't relate to nodes in the webdb; only to pages. Nothing to do here.
  def propagate_node_ids
    @nodes_by_pk.each do |node_pk, node|
      # Simpler propagation of node ID only:
      set_node_ids(@sci_names_by_node_pk, node_pk, node.id)
      set_node_ids(@vernaculars_by_node_pk, node_pk, node.id)
      # TODO: ...refs, links, image_infos.
      update_page(node)
      update_parents_and_ancestors(node_pk, node)
    end
  end

  def set_node_ids(hash, node_pk, node_id)
    return unless hash.key?(node_pk) # Not all nodes have all relationships available, of course. Avoids nil error.
    hash[node_pk].compact.each do |struct|
      struct.node_id = node_id
    end
  end

  def update_page(node)
    # puts "Page #{node.page_id} changing native node id from #{@pages[node.page_id].native_node_id} to #{node.id}"
    @pages[node.page_id].native_node_id = node.id # TODO: is this safe? Don't want to trample a node from DWH.
  end

  def update_parents_and_ancestors(node_pk, node)
    return if node.parent_resource_pk.blank?
    unless @nodes_by_pk.key?(node.parent_resource_pk)
      log_warn "WARNING: missing parent with res_pk: #{node.parent_resource_pk} ... I HOPE YOU ARE JUST TESTING!"
      return
    end
    node.parent_id = @nodes_by_pk[node.parent_resource_pk].id
    @ancestors_by_node_pk[node_pk].compact.each do |ancestor|
      ancestor.node_id = node.id
      unless @nodes_by_pk.key?(ancestor.ancestor_resource_pk)
        log_warn "WARNING: missing ancestor with res_pk: #{ancestor.ancestor_resource_pk} ...I HOPE YOU ARE JUST TESTING!"
        return
      end
      ancestor.ancestor_id = @nodes_by_pk[ancestor.ancestor_resource_pk].id
    end
  end

  def load_pages
    update_page_counts(WebDb.pages_to_update(@pages.keys))
    temp_table = WebDb.create_temp_pages_table(@resource.id)
    begin
      load_hashes_from_array(@pages.values, table: temp_table, replace: true)
      WebDb.load_pages_from_temp(temp_table)
    ensure
      WebDb.drop_temp_pages_table(temp_table)
    end
  end

  def update_page_counts(pages)
    col = {}
    Struct::WebPage.members.each_with_index { |name, i| col[name] = i }
    pages.each do |page|
      id = page[0] # ID MUST be the 0th column
      @pages[id].native_node_id = page[col[:native_node_id]]
      @pages[id].media_count += page[col[:media_count]]
      @pages[id].articles_count += page[col[:articles_count]]
      @pages[id].links_count += page[col[:links_count]]
      @pages[id].maps_count += page[col[:maps_count]]
      @pages[id].nodes_count += page[col[:nodes_count]]
      @pages[id].vernaculars_count += page[col[:vernaculars_count]]
      @pages[id].scientific_names_count += page[col[:scientific_names_count]]
    end
  end

  def load_hashes_from_array(array, options = {})
    return nil if array.empty?
    table = options[:table] || array.first.class.name.split(':').last.underscore.pluralize.sub('web_', '')
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
      log_warn "Wrote to #{file.path} in #{Time.delta_s(t)}"
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
    return @languages[language.code] if @languages.key?(language.code)
    log_warn("Encountered new language, please assign it to a language group and give it a name: #{language}")
    @languages[language.code] = WebDb.raw_create('languages', code: language.code, group: language.group_code)
  end

  def get_taxonomic_status(full_name)
    name = full_name&.downcase
    name = 'accepted' if name.blank? # Empty taxonomic_statuses are NOT allowed; this is the default assumption.
    return @taxonomic_statuses[name] if @taxonomic_statuses.key?(name)
    log_warn('Encountered new taxonomic status, please assign set its '\
             "alternative/preferred/problematic/mergeable: #{name}")
    @taxonomic_statuses[name] = WebDb.raw_create('taxonomic_statuses', name: name)
  end

  def log_warn(message)
    @logger.log(message, cat: :warns)
  end
end
