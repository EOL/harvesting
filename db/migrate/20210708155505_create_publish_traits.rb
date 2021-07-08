class CreatePublishTraits < ActiveRecord::Migration[5.2]
  def change
    create_table :publish_traits do |t|
      t.string :eol_pk
      t.integer :page_id
      t.string :scientific_name
      t.string :resource_pk
      t.string :predicate_uri
      t.string :sex_uri
      t.string :lifestage_uri
      t.string :statistical_method_uri
      t.integer :object_page_id
      t.string :target_scientific_name
      t.string :value_uri
      t.text :literal
      t.string :measurement
      t.string :units_uri
      t.string :normal_measurement
      t.string :normal_units_uri
      t.text :sample_size
      t.text :citation
      t.text :source
      t.text :remarks
      t.text :method
      t.string :contributor_uri
      t.string :compiler_uri
      t.string :determined_by_uri

      t.timestamps
    end
  end
end
