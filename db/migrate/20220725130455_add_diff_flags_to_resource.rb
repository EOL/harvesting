# 20220412125710
class RenameResourcesPublishStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :resources, :requires_full_reharvest_after, :datetime, null: true, default: nil
  end
end
