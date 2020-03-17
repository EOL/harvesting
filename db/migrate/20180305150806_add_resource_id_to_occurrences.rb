class AddResourceIdToOccurrences < ActiveRecord::Migration[4.2]
  def change
    add_column :occurrences, :resource_id, :integer
  end
end
