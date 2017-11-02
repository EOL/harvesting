class AddResPkToOccurrenceMetadata < ActiveRecord::Migration
  def change
    add_column :occurrence_metadata, :occurrence_resource_pk, :string, index: true
  end
end
