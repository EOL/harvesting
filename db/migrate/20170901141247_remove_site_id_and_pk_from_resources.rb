class RemoveSiteIdAndPkFromResources < ActiveRecord::Migration
  def change
    # We don't need these until we have multiple harvesting sites, which we don't, yet.
    remove_column :resources, :site_id
    remove_column :resources, :site_pk
  end
end
