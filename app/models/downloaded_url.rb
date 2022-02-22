# Just a unique identifier to help us build a single place to store images that we download from URLs.
class DownloadedUrl < ApplicationRecord
  belongs_to :medium
  before_save :hash_url

  def self.heal
    Medium.where('source_url IS NOT NULL AND downloaded_url_id IS NULL').find_in_batches do |batch|
      # First look to see if they already exist, which can happen:
      already_exist_by_id = DownloadedUrl.where(id: batch.map(&:id)).select('id').index_by(&:id)
      # TODO: test whether import! can actually set the PK id. :S
      downloaded_urls = []
      puts "Populating #{batch.size} media into downloaded_urls..."
      batch.each do |medium|
        next if already_exist_by_id[medium.id] # Skip it, will get healed soon without create
        downloaded_urls << DownloadedUrl.new(id: medium.id, resource_id: medium.resource_id, url: medium.source_url,
          md5_hash: Digest::MD5.hexdigest(medium.source_url))
      end
      DownloadedUrl.import!(downloaded_urls)
    end
    Medium.update_all("downloaded_url_id = id")
  end

  # URL is NOT guaranteed to be unique! It is only unique within A RESOURCE. Keep that in mind.
  def self.by_url_and_resource_id(url, resource_id)
    md5_hash = Digest::MD5.hexdigest(url)
    self.find_by_md5_hash_and_resource_id(md5_hash, resource_id)
  end

  def hash_url
    self[:md5_hash] = Digest::MD5.hexdigest(self[:url])
  end
end
