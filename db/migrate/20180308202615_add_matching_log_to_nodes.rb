class AddMatchingLogToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :matching_log, :text, comment: 'Log for all names matched on this node.'
  end
end
