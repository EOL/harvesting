# 20221206085744
class RenameMediaSubclassToSubcateogry < ActiveRecord::Migration[5.2]
  def change
    rename_column :media, :subclass, :subcategory
  end
end