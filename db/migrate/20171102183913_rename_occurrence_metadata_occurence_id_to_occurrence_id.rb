class RenameOccurrenceMetadataOccurenceIdToOccurrenceId < ActiveRecord::Migration[4.2]
  def change
    rename_column :occurrence_metadata, :occurence_id, :occurrence_id
  end
end
