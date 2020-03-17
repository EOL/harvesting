class UnlimitAttributions < ActiveRecord::Migration[4.2]
  def change
    change_column :content_attributions, :attribution_id, :integer, null: true
    change_column :content_attributions, :content_id, :integer, null: true
  end
end
