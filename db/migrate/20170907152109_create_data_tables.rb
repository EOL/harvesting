class CreateDataTables < ActiveRecord::Migration
  def change
    # This is a way-station for data read in before we populate "traits".
    create_table :occurrences do |t|
      t.integer :harvest_id # We don't need the resource id; this is "temporary" data and won't be handled much.
      t.string :resource_pk, null: false # e.g. OccurrenceID
      t.integer :node_id # e.g. TaxonID found using node_resource_pk
      t.string :node_resource_pk, null: false  # Temp. storage until we resolve and move to node_id.
      t.string :sex_term_id
      t.string :lifestage_term_id
    end

    create_table :occurrence_metadata do |t|
      t.integer :occurence_id
      t.integer :predicate_term_id
      t.integer :object_term_id
      t.text :literal
    end

    # Another "waystation" for data that will be used elsewhere...
    create_table :agents do |t|
      t.integer :harvest_id # We don't need the resource id; this is "temporary" data and won't be handled much.
      t.string :resource_pk, null: false
      t.string :full_name
      t.string :role
      t.string :email
      t.string :uri
      t.text :other_info
    end
  end
end
