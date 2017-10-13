# See Flattener class.
class NodeAncestor < ActiveRecord::Base
  belongs_to :node, inverse_of: :node_ancestors
  belongs_to :ancestor, class_name: 'Node', inverse_of: :descendants
end


# node_ancestors:
#   node_id: 2
#   ancestor_id: 1
#
#   node_id: 3
#   ancestor_id: 2
#
#   node_id: 3
#   ancestor_id: 1
