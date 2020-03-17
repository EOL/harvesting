class AddResourcePkToScientificNames < ActiveRecord::Migration[4.2]
  def change
    add_column :scientific_names, :resource_pk, :string
  end
end
