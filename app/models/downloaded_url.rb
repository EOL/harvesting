# Just a unique identifier to help us build a single place to store images that we download from URLs.
class DownloadedUrl < ApplicationRecord
  belongs_to :medium
  before_save :hash_url

  def self.by_url(url)
    md5_hash = Digest::MD5.hexdigest(url)
    self.find_by_md5_hash(md5_hash)
  end

  def hash_url
    self[:md5_hash] = Digest::MD5.hexdigest(self[:url])
  end
end
