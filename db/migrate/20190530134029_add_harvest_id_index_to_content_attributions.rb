class AddHarvestIdIndexToContentAttributions < ActiveRecord::Migration
  def change
    add_index :content_attributions, :harvest_id, name: 'index_content_attributions_on_harvest_id', using: :btree
  end
end
