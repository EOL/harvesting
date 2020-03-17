class AddingRefsToTraits < ActiveRecord::Migration[4.2]
  def change
    # This is a little misleading, but it's something I decided we need at this point, sooo...
    change_column :resources, :abbr, :string, limit: 16, unique: true, nil: false
    remove_index :resources, :name
    add_index :resources, :abbr, unique: true
  end
end
