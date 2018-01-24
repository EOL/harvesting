# Publish to the website database as quick as you can, please.
class Publisher
  attr_accessor :resource, :nodes, :nodes_by_pk, :identifiers_by_node_pk

  def self.by_resource(resource_in)
    new(resource: resource_in).by_resource
  end

  def initialize(options = {})
    @resource = options[:resource]
    reset_nodes
    @nodes_by_pk = {}
    @identifiers_by_node_pk = {}
    @ranks = {}
    @types = %w[node identifier scientific_name node_ancestor vernacular medium image_info page_content]
  end

  def reset_nodes
    @nodes = {}
  end

  def by_resource
    build_structs
    build_ranks
    slurp_nodes
    reset_nodes # We no longer need it, free up the memory.
    remove_old_data
    load_hashes
    # TODO: would be nice to remove pages that are no longer needed, but that is rather slow.
  end

  def build_structs
    # TODO: more, of course.
    @types.each do |type|
      attributes = WebDb.columns(type.pluralize)
      Struct.new("Web#{type.camelize}", *attributes)
    end
  end

  def build_ranks
    @ranks = WebDb.to_hash('ranks', 'name')
  end

  def slurp_nodes
    @nodes = @resource.nodes.includes(:scientific_name, :identifiers, :node_ancestors)
    @nodes.find_in_batches(batch_size: 10_000) do
      nodes_to_hashes
    end
  end

  def nodes_to_hashes
    @nodes.each do |node|
      next if @nodes_by_pk.key?(node.resource_pk)
      node_to_struct(node)
    end
  end

  def node_to_struct(node)
    # TODO: node_ancestors, rank_id, parent_id, children_count
    # Ignoring: is_hidden, timestamps,

    same_attributes = %i[page_id parent_resource_pk in_unmapped_area resource_pk landmark source_url]
    @nodes_by_pk[node.resource_pk] = Struct::WebNode.new
    same_attributes.each do |field|
      @nodes_by_pk[node.resource_pk][field] = node[field]
    end
    @nodes_by_pk[node.resource_pk][:canonical_form] = node.safe_canonical
    @nodes_by_pk[node.resource_pk][:scientific_name] = node.safe_scientific
    @nodes_by_pk[node.resource_pk][:has_breadcrumb] = !node.no_landmark?
    @nodes_by_pk[node.resource_pk][:rank_id] = get_rank(node.rank)
    node.identifiers.each do |ider|
      @identifiers_by_node_pk[node.resource_pk] = Struct::WebIdentifier.new(ider.identifier, node.resource_pk)
    end
  end

  def remove_old_data
    @types.each do |type|
      table = type.pluralize
      WebDb.remove_resource_data(table, @resource.id)
    end
  end

  def load_hashes
    debugger
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
