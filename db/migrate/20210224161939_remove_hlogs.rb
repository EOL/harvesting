class RemoveHlogs < ActiveRecord::Migration[5.2]
  def up
    drop_table :hlogs
  end

  def down
    raise ActiveRecord::IrreversibleMigration.new("Cannot rebuild hlogs table")
  end
end
