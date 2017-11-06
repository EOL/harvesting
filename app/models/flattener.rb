class Flattener
  attr_reader :ancestry

  def self.flatten(resource)
    flattener = self.new(resource)
    flattener.flatten
  end

  def initialize(resource)
    @resource = resource
  end

  def flatten
    puts("Flattener.flatten(#{@resource.id}) #{@resource.name}")
    study_resource
    return if @children.empty?
    build_ancestry
    build_node_ancestors
    update_tables
  end

  private

  def study_resource
    @children = {}
    Node.where(resource_id: @resource.id).published.pluck("CONCAT_WS(',', id, parent_id) ids").each do |str|
      (entry,parent) = str.split(',')
      @children[parent] ||= []
      @children[parent] << entry
    end
  end

  def build_ancestry
    @ancestry = {}
    walk_down_tree(nil, [])
  end

  def walk_down_tree(id, ancestors)
    return unless @children.has_key?(id)
    ancestors_here = ancestors.dup
    ancestors_here << id
    @children[id].each do |child_id|
      @ancestry[child_id] = ancestors_here
      walk_down_tree(child_id, ancestors_here)
    end
  end

  def build_node_ancestors
    @node_ancestors = []
    @ancestry.keys.each do |child|
      @ancestry[child].each_with_index do |ancestor, depth|
        next if ancestor.nil? # No need to store this one.
        @node_ancestors <<
          NodeAncestor.new(node_id: child, ancestor_id: ancestor, resource_id: @resource.id, depth: depth)
      end
    end
    # Without returning something simple, the return value is huge, slowing things down.
    true
  end

  def update_tables
    NodeAncestor.where(resource_id: @resource.id).delete_all
    # TODO: error-handling
    puts("Flattening #{@node_ancestors.size} ancestors")
    NodeAncestor.import! @node_ancestors
    NodeAncestor.propagate_id(fk: 'ancestor_id', other: 'nodes.id', set: 'ancestor_fk', with: 'resource_pk')
  end
end
