class RemoveHarevstIdFromFormats < ActiveRecord::Migration[5.2]
  def change
    Format.where('harvest_id IS NOT NULL').delete_all
    remove_column :harvest_id, :formats
  end
end
