class ResourceDownloadWorker
  @queue = "downloads"
  def perform(resource_id)
    resource = Resource.find(resource_id)
    begin
      resource.download
    rescue Eol::RemoteFileMissing => e
      # email watchers
    rescue Eol::InvalidFileFormat => e
      # etc...
    end
    resouce.enqueue_validation
    Resource.enqueue_pending_harvests
  end
end

class ResourceMediaDownloadWorker
  @queue = "downloads"
  def perform(resource_id)
    resource = Resource.find(resource_id)
    begin
      resource.download_media
    rescue Eol::RemoteFileMissing => e
      # email watchers
    rescue Eol::InvalidFileFormat => e
      # etc...
    end
    resouce.enqueue_...TODO
  end
end

class ResourceValidationWorker
  @queue = "harvesting"
  def perform(resource_id)
    resource = Resource.find(resource_id)
    begin
      resource.validate
    rescue Eol::ValidationError => e
      # Email watchers
    end
    resource.enqueue_media_downloads
  end
end

class Resource
  scope :pending_harvest { where("complex query here") }
  def self.enqueue_pending_harvests
    Resource.pending_harvest.each { |resource| resource.enqueue_download }
  end

  def download
    # NOTE Actually belongs in its own class.
    # look for the file online
    # fetch it if it needs refreshing
    # unzip it if needed
    # log errors & raise exceptions if invalid, missing, etc...
  end

  def enqueue_download
    Resqueue.enqueue(ResourceValidationWorker, resource_id: id)
  end

  def enqueue_media_downloads
    Resqueue.enqueue(ResourceMediaDownloadWorker, resource_id: id)
  end

  def enqueue_validation
    Resqueue.enqueue(ResourceValidationWorker, resource_id: id)
  end

  def validate
    # NOTE Actually belongs in its own class.
    # Check the file format
    # Check the metadata
    # Check that the fields match expected fields
    # Check for obvious problems in the data (many of these)
    # log errors (ValidationLog)for all problems (many of these).
    # Raise exceptions for critical problems
    # Store a normalized, validated file
  end
end
