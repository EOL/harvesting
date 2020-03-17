class AddTimestampsToHarvestProcesses < ActiveRecord::Migration[4.2]
  def change
    add_column :harvest_processes, :created_at, :datetime, null: false
    add_column :harvest_processes, :updated_at, :datetime, null: false
  end
end
