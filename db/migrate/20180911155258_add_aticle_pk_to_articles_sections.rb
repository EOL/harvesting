# 20180911155258
class AddAticlePkToArticlesSections < ActiveRecord::Migration[4.2]
  def change
    add_column :articles_sections, :article_pk, :string, null: false
    add_column :articles_sections, :harvest_id, :integer, null: false
    add_column :articles_sections, :id, :primary_key # Yes, really, this was created without an ID
    change_column_null :articles_sections, :article_id, true # We're allowing nulls before id propagation.
  end
end
