# Just a unique identifier to help us build a single place to store images that we download from URLs.
class DownloadedUrl < ApplicationRecord
  belongs_to :medium
  before_save :hash_url

  # NOTE: this is slow. I tried doing things in bulk, but validating against duplicates was too expensive. Alas.
  # ...but feel free to take another whack at it if you are so inclined. Just be aware that duplicate URLs *are* allowed
  # (and DO occur) within a resource, so they should all point to the first DownloadedUrl that is created.
  def self.heal
    Medium.where('source_url IS NOT NULL AND downloaded_url_id IS NULL').find_in_batches do |batch|
      downloaded_urls = []
      puts "Populating #{batch.size} media into downloaded_urls..."
      batch.each do |medium|
        medium.create_downloaded_url
      end
      DownloadedUrl.import!(downloaded_urls)
    end
  end

  # the md5_hash is NOT guaranteed to be unique! It is only unique within A RESOURCE. Keep that in mind.
  def self.by_url_and_resource_id(url, resource_id)
    md5_hash = Digest::MD5.hexdigest(url)
    self.find_by_md5_hash_and_resource_id(md5_hash, resource_id)
  end

  def hash_url
    self[:md5_hash] = Digest::MD5.hexdigest(self[:url])
  end
end
