class AddResourcePkToScientificNames < ActiveRecord::Migration
  def change
    add_column :scientific_names, :resource_pk, :string
  end
end
