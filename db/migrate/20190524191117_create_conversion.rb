# 20190524191117
class CreateConversion < ActiveRecord::Migration
  def change
    create_table :processes do |t|
      t.integer :resource_id
      t.text :method_breadcrumbs, comment: 'comma-separated list of method names currently nested into'
      t.integer :current_group, comment: 'index of current group being processed'
      t.integer :current_group_size, comment: 'number of groups currently being processed'
      t.text :current_group_times, comment: 'comma-separated list of seconds required per group'
    end

    add_column :resources, :skips, :text, comment: 'comma-separated list of method names to skip'
  end
end
