class MoveProcessesToHarvestProcesses < ActiveRecord::Migration
  def change
    rename_table :processes, :harvest_processes
  end
end
