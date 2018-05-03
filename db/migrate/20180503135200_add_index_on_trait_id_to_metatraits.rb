class AddIndexOnTraitIdToMetatraits < ActiveRecord::Migration
  def change
    add_index :meta_traits, :trait_id # We really only need this for admins, but it stings without it!
  end
end
