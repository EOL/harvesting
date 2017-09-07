class CreateDataTables < ActiveRecord::Migration
  def change
    # This is a way-station for data read in before we populate "traits".
    create_table :occurrences do |t|
      t.integer :harvest_id # We don't need the resource id; this is "temporary" data and won't be handled much.
      t.string :resource_pk, null: false # e.g. OccurrenceID
      t.integer :node_id, null: false # e.g. discovered via TaxonID
      t.string :sex
      t.string :lifestage
      t.string :lat
      t.string :long
      t.string :locality
    end

    create_table :occurrence_metadata do |t|
      t.integer :occurence_id
      t.string :header  # This is just for debugging convenience.
      t.integer :predicate_term_id
      t.text :value
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

    delete_column :formats, :position # The order needs to be fixed, not user-specified.
  end
end
