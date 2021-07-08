class RemoveEolPkFromPublishMetadata < ActiveRecord::Migration[5.2]
  def change
    remove_column :publish_metadata, :eol_pk
  end
end
