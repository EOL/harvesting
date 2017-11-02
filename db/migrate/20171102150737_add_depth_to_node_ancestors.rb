class AddDepthToNodeAncestors < ActiveRecord::Migration
  def change
    add_column :node_ancestors, :depth, :integer
    add_column :node_ancestors, :ancestor_fk, :string
  end
end
