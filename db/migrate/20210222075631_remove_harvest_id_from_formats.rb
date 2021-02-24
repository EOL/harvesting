class RemoveHarevstIdFromFormats < ActiveRecord::Migration[5.2]
  def up
    remove_column :formats, :harvest_id
    remove_column :formats, :diff, :string
    Format.where('harvest_id IS NOT NULL').delete_all
  end

  def down
    add_column :formats, :harvest_id, :integer
    add_column :formats, :diff, :string
  end
end
