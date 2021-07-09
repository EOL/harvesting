class RemoveTraitEolPkFromPublishMetadata < ActiveRecord::Migration[5.2]
  def change
    remove_column :publish_metadata, :trait_eol_pk
  end
end
