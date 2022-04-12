# 20220412125710
class RenameResourcesPublishStatus < ActiveRecord::Migration[5.2]
  def change
    rename_column :resources, :publish_status, :harvest_status
  end
end
