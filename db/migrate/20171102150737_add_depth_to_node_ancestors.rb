class AddDepthToNodeAncestors < ActiveRecord::Migration[4.2]
  def change
    add_column :node_ancestors, :depth, :integer
    add_column :node_ancestors, :ancestor_fk, :string
  end
end
