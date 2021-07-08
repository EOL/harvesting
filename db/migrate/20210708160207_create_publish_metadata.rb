class CreatePublishMetadata < ActiveRecord::Migration[5.2]
  def change
    create_table :publish_metadata do |t|
      t.string :eol_pk
      t.string :trait_eol_pk
      t.string :predicate_uri
      t.text :literal
      t.string :measurement
      t.string :value_uri
      t.string :units_uri
      t.string :sex_uri
      t.string :lifestage_uri
      t.string :statistical_method_uri
      t.text :source
      t.boolean :is_external
      t.integer :publish_trait_id

      t.timestamps
    end
  end
end
