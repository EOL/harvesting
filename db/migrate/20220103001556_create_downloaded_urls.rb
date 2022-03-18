class CreateDownloadedUrls < ActiveRecord::Migration[5.2]
  def change # utf8_unicode_ci
    create_table :downloaded_urls, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
      t.integer :resource_id
      t.string :url, limit: 2083
      t.string :md5_hash, limit: 32

      t.timestamps
    end
    add_index :downloaded_urls, :resource_id
    add_index :downloaded_urls, :md5_hash
    add_column :media, :downloaded_url_id, :integer
    DownloadedUrl.heal
  end
end
