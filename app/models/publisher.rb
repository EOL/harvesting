# Publish to the website database as quick as you can, please.
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
    @ranks = {}
    @types = %w[node identifier scientific_name node_ancestor vernacular medium image_info page_content]
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

  def slurp_nodes
    # TODO: REPLAAAAAAAAAAAAAAAAAAAAAAAAAAACE MEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE !!!!!!!!!!!!!!!!! TEMP TEMP TEMP
    @nodes = @resource.nodes.includes(:scientific_name, :identifiers, :node_ancestors)
    @nodes.find_in_batches(batch_size: 10_000) do
    # @nodes = @resource.nodes.includes(:scientific_name, :identifiers, :node_ancestors).limit(100)
    # @nodes.each do
      nodes_to_hashes
    end
  end

  def nodes_to_hashes
    @nodes.each do |node|
      next if @nodes_by_pk.key?(node.resource_pk)
      node_to_struct(node)
      build_identifiers(node)
      build_ancestors(node)
      # TODO: scientific_names, etc...
    end
  end

  def node_to_struct(node)
    same_attributes = %i[page_id parent_resource_pk in_unmapped_area resource_pk landmark source_url]
    web_node = Struct::WebNode.new
    same_attributes.each do |field|
      web_node[field] = clean_values(node[field])
    end
    now = Time.now.to_s(:db)
    web_node.resource_id = @web_resource_id
    web_node.canonical_form = clean_values(node.safe_canonical)
    web_node.scientific_name = clean_values(node.safe_scientific)
    web_node.has_breadcrumb = clean_values(!node.no_landmark?)
    web_node.rank_id = get_rank(node.rank)
    web_node.is_hidden = 0
    web_node.created_at = now
    web_node.updated_at = now
    @nodes_by_pk[node.resource_pk] = web_node
  end

  def clean_values(val)
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

  def remove_old_data
    @types.each do |type|
      table = type.pluralize
      WebDb.remove_resource_data(table, @resource.id)
    end
  end

  def load_hashes
    t = Time.now
    load_hashes_from_array(@nodes_by_pk.values)
    puts "Loaded nodes in #{took = Time.delta_s(t)}"
    t = Time.now
    learn_node_ids
    propagate_node_ids
    puts "Propagated node IDs in #{took = Time.delta_s(t)}"
    t = Time.now
    load_hashes_from_array(@nodes_by_pk.values, replace: true)
    puts "Re-loaded nodes in #{took = Time.delta_s(t)}"
    t = Time.now
    load_hashes_from_array(@ancestors_by_node_pk.values.flatten)
    puts "Loaded node ancestors in #{took = Time.delta_s(t)}"
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
      # TODO: the whole of node_ancestors... many of the relationships on the other models, like scientific_names...
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
