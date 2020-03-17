# 20181218202746
class UpdateArticleIndexes < ActiveRecord::Migration[4.2]
  def change
    remove_index :articles, name: 'index_articles_on_harvest_id_and_resource_pk'
    add_index :articles, :node_resource_pk, name: 'node_resource_pk', length: { node_resource_pk: 191 }
    add_index :articles, :resource_pk, name: 'resource_pk', length: { resource_pk: 191 }
  end
end
