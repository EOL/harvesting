class AddResourceIdToOccurrences < ActiveRecord::Migration
  def change
    add_column :occurrences, :resource_id, :integer
  end
end
