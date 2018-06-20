# 20161121181833
class InitialUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.text :description
      # TODO: icons and the like...
    end

    create_join_table :users, :partners
  end
end
