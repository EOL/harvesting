class RenameOccurrenceMetadataOccurenceIdToOccurrenceId < ActiveRecord::Migration
  def change
    rename_column :occurrence_metadata, :occurence_id, :occurrence_id
  end
end
