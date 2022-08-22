class EnqueueMediaDownloadJob < HarvestingBaseJob
  def perform
    Admin.maintain_db_connection
    Resource.find(resource_id).download_batch_of_missing_images
  end

  def queue_name
    'media'
  end
end
