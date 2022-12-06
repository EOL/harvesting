# 20221206085744
class AddIndexToOccurrencesMetadata < ActiveRecord::Migration[5.2]
  def change
    add_index "occurrence_metadata", "occurrence_id"
  end
end