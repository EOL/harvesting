class ReHarvestJob < HarvestingBaseJob
  def perform
    Admin.maintain_db_connection
    Resource.find(resource_id).re_harvest
  end

  def after(_job)
    Rails.logger.info("Finished ReHarvestJob for Resource##{resource_id}")
    Resource.find(resource_id).unlock rescue nil
  end
end
