class AddOpendataUrlToResources < ActiveRecord::Migration
  def change
    add_column :resources, :opendata_url, :string
  end
end
