class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :name
      t.integer :position
    end

    create_table :section_parents do |t|
      t.integer :section_id
      t.integer :parent_id
    end

    create_table :section_values do |t|
      t.integer :section_id
      t.string :value, index: true
    end

    DefaultSections.create
  end
end
