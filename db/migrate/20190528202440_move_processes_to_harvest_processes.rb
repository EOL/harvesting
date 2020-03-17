class MoveProcessesToHarvestProcesses < ActiveRecord::Migration[4.2]
  def change
    rename_table :processes, :harvest_processes
  end
end
