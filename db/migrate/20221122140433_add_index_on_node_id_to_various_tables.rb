# 20220412125710
class AddIndexOnNodeIdToVariousTables < ActiveRecord::Migration[5.2]
  def change
    add_index :articles, :node_id
    add_index :vernaculars, :node_id
    add_index :occurrences, :node_id
    add_index :traits, :node_id
  end
end