class AddHarvestIdToPublishModels < ActiveRecord::Migration[5.2]
  def change
    add_column :publish_traits, :harvest_id, :integer
    add_column :publish_metadata, :harvest_id, :integer
  end
end
