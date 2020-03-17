class AddOpendataUrlToResources < ActiveRecord::Migration[4.2]
  def change
    add_column :resources, :opendata_url, :string
  end
end
