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
    @web_resource_id = nil
    reset_nodes
    @nodes_by_pk = {}
    @identifiers_by_node_pk = {}
    @ancestors_by_node_pk = {}
    @sci_names_by_node_pk = {}
    @taxonomic_statuses = {}
    @ranks = {}
    @types = %w[node identifier scientific_name node_ancestor vernacular medium image_info page_content]
    @same_sci_name_attributes =
      %i[italicized genus specific_epithet infraspecific_epithet infrageneric_epithet uninomial verbatim
         authorship publication remarks parse_quality year hybrid surrogate virus]
    @same_node_attributes = %i[page_id parent_resource_pk in_unmapped_area resource_pk source_url]
  end

  def reset_nodes
    @nodes = {}
  end

  def by_resource
    build_structs
    build_ranks
    learn_resource_id
    t = Time.now
    slurp_nodes
    puts "Slurped in #{took = Time.delta_s(t)}"
    reset_nodes # We no longer need it, free up the memory.
    t = Time.now
    count_children
    puts "Counted children in #{took = Time.delta_s(t)}"
    t = Time.now
    remove_old_data
    puts "Removed old data in #{took = Time.delta_s(t)}"
    t = Time.now
    load_hashes
    puts "Loaded new data in #{took = Time.delta_s(t)}"
    # TODO: Ensure nothing ended up with node_id = 0 (sci names, at least...)
  end

  def build_structs
    @types.each do |type|
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

  # TODO: REPLAAAAAAAAAAAAAAAAAAAAAAAAAAACE MEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE !!!!!!!!!!!!!!!!! TEMP TEMP TEMP
  def slurp_nodes
    # TODO: vernaculars, media, refs, articles, links.
    @nodes = @resource.nodes.published.includes(:identifiers, :node_ancestors, scientific_names: [:dataset])
                      .limit(100) # <-- For testing only.
    # @nodes.find_in_batches(batch_size: 10_000) do
    @nodes.each do
      nodes_to_hashes
    end
  end

  def nodes_to_hashes
    @nodes.each do |node|
      next if @nodes_by_pk.key?(node.resource_pk)
      node_to_struct(node)
      build_identifiers(node)
      build_ancestors(node)
      build_scientific_names(node)
      # TODO: vernaculars, media, refs, articles, links.
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
    load_hashes_from_array(@nodes_by_pk.values, replace: true)
    load_hashes_from_array(@ancestors_by_node_pk.values.flatten)
    load_hashes_from_array(@sci_names_by_node_pk.values.flatten)
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
      # TODO: the whole of node_ancestors... many of the relationships on the other models, like vernaculars, media,
      # refs, articles, links.
      unless @nodes_by_pk.key?(node.parent_resource_pk)
        puts "WARNING: missing parent with res_pk: #{node.parent_resource_pk} ... I HOPE YOU ARE JUST TESTING!"
        next
      end
      node.parent_id = @nodes_by_pk[node.parent_resource_pk].id
      @ancestors_by_node_pk[node_pk].compact.each do |ancestor|
        ancestor.node_id = node.id
        unless @nodes_by_pk.key?(ancestor.ancestor_resource_pk)
          puts "WARNING: missing ancestor with res_pk: #{ancestor.ancestor_resource_pk} ... I HOPE YOU ARE JUST TESTING!"
          next
        end
        ancestor.ancestor_id = @nodes_by_pk[ancestor.ancestor_resource_pk].id
      end
      @sci_names_by_node_pk[node_pk].compact.each do |name|
        name.node_id = node.id
      end
    end
  end

  def load_hashes_from_array(array, options = {})
    t = Time.now
    table = array.first.class.name.split(':').last.underscore.pluralize.sub('web_', '')
    file = Tempfile.new("rails.eol_website.#{table}")
    begin
      write_local_csv(file, array, options)
      puts "Wrote to #{file.path} in #{took = Time.delta_s(t)}"
      cols = unless options[:replace]
               c = array.first.members
               c.delete(:id)
               c
             end
      WebDb.import_csv(file.path, table, cols)
    ensure
      File.unlink(file)
    end
  end

  def write_local_csv(file, structs, options = {})
    table = structs.first.class.name.split(':').last.underscore.pluralize
    # CSV.open(file, 'wb', encoding: 'ISO-8859-1', col_sep: "\t") do |csv|
    CSV.open(file, 'wb', col_sep: "\t") do |csv|
      structs.each do |struct|
        # I hate MySQL serialization. Nulls are stored as \N (literally).
        line = struct.to_a.map { |v| v.nil? ? '\\N' : v }
        # NO ID specified if it's a first-time insert...
        line.delete_at(struct.members.index(:id)) unless options[:replace]
        csv << line
      end
    end
  end

  def get_rank(full_rank)
    return nil if full_rank.nil?
    rank = full_rank.downcase
    return nil if rank.blank?
    return @ranks[rank] if @ranks.key?(rank)
    @ranks[rank] = WebDb.raw_create_rank(rank)
  end

  def get_taxonomic_status(full_name)
    return nil if full_name.nil?
    name = full_name.downcase
    return nil if name.blank?
    return @taxonomic_statuses[name] if @taxonomic_statuses.key?(name)
    @taxonomic_statuses[name] = WebDb.raw_create('taxonomic_statuses', name: name)
  end
end
