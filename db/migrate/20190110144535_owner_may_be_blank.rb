class OwnerMayBeBlank < ActiveRecord::Migration
  def up
    change_column :articles, :owner, :text, limit: 65535, null: true
    change_column :media, :owner, :text, limit: 65535, null: true
  end
  def down
    change_column :articles, :owner, :text, limit: 65535, null: false
    change_column :media, :owner, :text, limit: 65535, null: false
  end
end
