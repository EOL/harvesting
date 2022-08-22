class ResumeHarvestJob < HarvestingBaseJob
  def perform
    Admin.maintain_db_connection
    Resource.find(resource_id).resume
  end

  def after(_job)
    Rails.logger.info("Finished ResumeHarvestJob for Resource##{resource_id}")
    Resource.find(resource_id).unlock rescue nil
  end
end
