class AddFieldsToScientificNames < ActiveRecord::Migration[4.2]
  def change
    add_column :scientific_names, :dataset_id, :string

    create_table :datasets, id: false do |t|
      t.string :id, null: false, index: true, unique: true
      t.text :name, null: false
      t.text :link, null: false
      t.string :publisher
      t.string :supplier
      t.text :metadata
    end
  end
end
