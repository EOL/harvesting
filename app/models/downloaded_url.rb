# Just a unique identifier to help us build a single place to store images that we download from URLs.
class DownloadedUrl < ApplicationRecord
  belongs_to :medium
  before_save :hash_url

  # URL is NOT guaranteed to be unique! It is only unique within A RESOURCE. Keep that in mind.
  def self.by_url_and_resource_id(url, resource_id)
    md5_hash = Digest::MD5.hexdigest(url)
    self.find_by_md5_hash_and_resource_id(md5_hash, resource_id)
  end

  def hash_url
    self[:md5_hash] = Digest::MD5.hexdigest(self[:url])
  end
end
