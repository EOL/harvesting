class AddParentEolPkToTraits < ActiveRecord::Migration[5.2]
  def change
    add_column :traits, :parent_eol_pk, :string
  end
end
