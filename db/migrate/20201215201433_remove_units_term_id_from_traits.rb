class RemoveUnitsTermIdFromTraits < ActiveRecord::Migration[5.2]
  def change
    remove_column :traits, :units_term_id
  end
end
