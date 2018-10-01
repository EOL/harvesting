class AddResourcePkToBibCit < ActiveRecord::Migration
  def change
    add_column :bibliographic_citations, :resource_pk, :string, null: false, index: true
    add_column :bibliographic_citations, :harvest_id, :integer, null: false
    add_column :bibliographic_citations, :resource_id, :integer, null: false
  end
end
