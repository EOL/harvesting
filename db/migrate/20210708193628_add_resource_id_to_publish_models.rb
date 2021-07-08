class AddResourceIdToPublishModels < ActiveRecord::Migration[5.2]
  def change
    add_column :publish_traits, :resource_id, :integer
    add_column :publish_metadata, :resource_id, :integer
  end
end
