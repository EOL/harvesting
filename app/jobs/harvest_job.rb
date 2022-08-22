class HarvestJob < HarvestingBaseJob
  def perform
    Admin.maintain_db_connection
    Resource.find(resource_id).harvest
  end

  def error(job, exception)
    Rails.logger.error("** HARVEST JOB ERROR: #{exception.message} TRACE: #{exception.backtrace.join("\n")}")
  end

  def after(_job)
    Rails.logger.info("Finished HarvestJob for Resource##{resource_id}")
    Resource.find(resource_id).unlock rescue nil
  end
end
