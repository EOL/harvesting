class RenameResourcesHasPersistentTraitPksToCanPerformTraitDiffs < ActiveRecord::Migration[5.2]
  def change
    rename_column :resources, :has_persistent_trait_pks, :can_perform_trait_diffs
  end
end
