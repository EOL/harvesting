class AddHasPersistentTraitPksToResources < ActiveRecord::Migration[5.2]
  def change
    add_column :resources, :has_persistent_trait_pks, :boolean, default: false
  end
end

