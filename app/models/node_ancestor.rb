# See Flattener class.
class NodeAncestor < ApplicationRecord
  establish_connection Rails.env.to_sym
  belongs_to :resource, inverse_of: :node_ancestors
  belongs_to :node, inverse_of: :node_ancestors
  belongs_to :ancestor, class_name: 'Node', inverse_of: :descendants

  def self.export_ancestry(resource)
    CSV.open(resource.path.join('publish_node_ancestor_pages.csv'), 'ab') do |csv|
      where(resource_id: resource.id).includes(:node, :ancestor).find_each do |nod_anc|
        csv << [nod_anc.node.page_id, nod_anc.ancestor.page_id] if nod_anc.node&.page_id && nod_anc.ancestor&.page_id
      end
    end
  end
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
