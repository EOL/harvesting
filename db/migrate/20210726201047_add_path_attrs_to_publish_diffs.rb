class AddPathAttrsToPublishDiffs < ActiveRecord::Migration[5.2]
  def change
    add_column :publish_diffs, :new_traits_path, :string
    add_column :publish_diffs, :removed_traits_path, :string
    add_column :publish_diffs, :new_metadata_path, :string
    add_column :publish_diffs, :remove_all_traits, :boolean
  end
end
