class AddResPkToOccurrenceMetadata < ActiveRecord::Migration[4.2]
  def change
    add_column :occurrence_metadata, :resource_id, :integer
    add_column :occurrence_metadata, :units_term_id, :integer
    add_column :occurrence_metadata, :statistical_method_term_id, :integer
    add_column :occurrence_metadata, :resource_pk, :string
    add_column :occurrence_metadata, :measurement, :string
    add_column :occurrence_metadata, :occurrence_resource_pk, :string, index: true
  end
end
