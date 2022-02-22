class AddConstraintToDownloadedUrls < ActiveRecord::Migration[5.2]
  def up
    q = "SELECT resource_id, md5_hash, count(*) FROM downloaded_urls GROUP BY resource_id, md5_hash HAVING count(*) > 1"
    results = DownloadedUrl.connection.query(q)
    results.each do |group|
      (resource_id, hash, _) = *group
      dl_urls = DownloadedUrl.where(resource_id: resource_id, md5_hash: hash)
      # Try the fast way first:
      media = Medium.where(id: dl_urls.map(&:id))
      if media.size != dl_urls.size
        # Slower:
        media = Medium.where(resource_id: resource_id, source_url: dl_urls.first.url)
      end
      media.update_all(downloaded_url_id: dl_urls.first.id)
      DownloadedUrl.where(id: dl_urls[1..-1].map(&:id)).destroy_all
    end
    q = "ALTER TABLE `downloaded_urls` ADD UNIQUE `resource_id_and_md5_hash`(`resource_id`, `md5_hash`)"
    DownloadedUrl.connection.execute(q)
  end
end
