class Flattener
  attr_reader :ancestry

  def self.flatten(resource, harvest)
    flattener = self.new(resource, harvest)
    flattener.flatten
  end

  def initialize(resource, harvest)
    @resource = resource
    @harvest = harvest
  end

  def flatten
    @harvest.log('Flattener#flatten', cat: :starts)
    study_resource
    if @children.empty?
      @harvest.log('NO CHILDREN FOUND', cat: :warns)
      return nil
    end
    build_ancestry
    build_node_ancestors
    update_tables
  end

  private

  def study_resource
    @harvest.log('Flattener#study_resource', cat: :starts)
    @children = {}
    Node.where(resource_id: @resource.id).published.pluck_in_batches(:id, :parent_id) do |batch|
      batch.each do |row|
        entry = row.first
        parent = row.last
        @children[parent] ||= []
        @children[parent] << entry
      end
    end
  end

  def build_ancestry
    @harvest.log('Flattener#build_ancestry', cat: :starts)
    @ancestry = {}
    walk_down_tree(nil, [])
  end

  def walk_down_tree(id, ancestors)
    return unless @children.has_key?(id)
    ancestors_here = ancestors.dup
    ancestors_here << id
    @children[id].each do |child_id|
      @ancestry[child_id] = ancestors_here
      @harvest.log("ancestry now has #{@ancestry.keys.size}") if (@ancestry.keys.size % 10_000).zero?
      walk_down_tree(child_id, ancestors_here)
    end
  end

  def build_node_ancestors
    @harvest.log("Flattener#build_node_ancestors (#{@ancestry.keys.size} ancestry keys)", cat: :starts)
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
    @harvest.log('Flattener#update_tables', cat: :starts)
    NodeAncestor.where(resource_id: @resource.id).delete_all
    # TODO: error-handling
    if @node_ancestors.empty?
      puts("NOTHING TO FLATTEN!")
    else
      puts("Flattening #{@node_ancestors.size} ancestors")
      NodeAncestor.import! @node_ancestors
      NodeAncestor.propagate_id(fk: 'ancestor_id', other: 'nodes.id', set: 'ancestor_fk', with: 'resource_pk')
    end
  end
end
