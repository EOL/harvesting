class CreateDownloadedUrls < ActiveRecord::Migration[5.2]
  def change
    create_table :downloaded_urls do |t|
      t.integer :resource_id
      t.string :url, limit: 2083
      t.string :md5_hash, limit: 32

      t.timestamps
    end
    add_index :downloaded_urls, :resource_id
    add_index :downloaded_urls, :md5_hash
    add_column :media, :downloaded_url_id, :integer
    downloaded_urls = []
    Medium.where('source_url IS NOT NULL').find_each do |medium|
      # TODO: test whether import! can actually set the PK id. :S
      downloaded_urls << DownloadedUrl.new(id: medium.id, resource_id: medium.resource_id, url: medium.source_url,
        md5_hash: Digest::MD5.hexdigest(medium.source_url))
    end
    DownloadedUrl.import!(downloaded_urls)
    Medium.update_all("downloaded_url_id = id")
  end
end
