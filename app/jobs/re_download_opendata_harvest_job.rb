class ReDownloadOpendataHarvestJob < HarvestingBaseJob
  def perform
    Admin.maintain_db_connection
    Resource.find(resource_id).re_download_opendata_and_harvest
  end

  def after(_job)
    Rails.logger.info("Finished ReDownloadOpendataHarvestJob for Resource##{resource_id}")
    Resource.find(resource_id).unlock rescue nil
  end
end
