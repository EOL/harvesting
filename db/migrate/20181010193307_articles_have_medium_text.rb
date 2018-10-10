class ArticlesHaveMediumText < ActiveRecord::Migration
  def change
    change_column :articles, :body, :text, limit: 16.megabytes - 1
  end
end
