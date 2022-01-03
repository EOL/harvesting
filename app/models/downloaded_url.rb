# Just a unique identifier to help us build a single place to store images that we download from URLs.
class DownloadedUrl < ApplicationRecord
  belongs_to :medium
end
