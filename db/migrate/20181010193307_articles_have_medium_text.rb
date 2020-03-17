class ArticlesHaveMediumText < ActiveRecord::Migration[4.2]
  def change
    change_column :articles, :body, :text, limit: 16.megabytes - 1
    Article.connection.execute(%{
      ALTER TABLE articles CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
      MODIFY `body` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
      MODIFY `owner` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
      MODIFY `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL;
    })
  end
end
