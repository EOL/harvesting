class RemoveContentJob < HarvestingBaseJob
  def perform
    Admin.maintain_db_connection
    resource = Resource.find(resource_id)
    message = "!! REMOVING CONTENT for resource #{resource.name} (##{resource.id})"
    Rails.logger.warn(message)
    Delayed::Worker.logger.warn(message)
    resource.remove_content_and_reset
    resource.harvests.each &:delete
    `echo "!! Reset log via RemoveContentJob on #{Time.now}" > #{resource.process_log_path}`
  end
end
