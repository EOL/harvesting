class AddFksToContentAttributions < ActiveRecord::Migration
  def change
    add_column :content_attributions, :content_resource_fk, :string, null: false
    add_column :content_attributions, :attribution_resource_fk, :string, null: false
    add_column :content_attributions, :resource_id, :integer, null: false
    add_column :content_attributions, :harvest_id, :integer, null: false

    add_index :content_attributions, %i[attribution_resource_fk harvest_id], name: 'by_harvest_attribution_resource_fk'
    add_index :content_attributions, %i[content_type content_resource_fk harvest_id],
              name: 'by_harvest_content_resource_fk'
  end
end
