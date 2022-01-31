# Quiet down the logs in production: https://github.com/collectiveidea/delayed_job/issues/477#issuecomment-800341818
module ::Delayed::Backend::ActiveRecord
  class Job < ::ActiveRecord::Base
  end
  Job.singleton_class.prepend(
    Module.new do
      def reserve(*)
        previous_level = ::ActiveRecord::Base.logger.level
        ::ActiveRecord::Base.logger.level = Logger::WARN if previous_level < Logger::WARN
        value = super
        ::ActiveRecord::Base.logger.level = previous_level
        value
      end
    end
  )
end

Delayed::Worker.logger = Logger.new(Rails.root.join('log', 'delayed_job.log'))
Delayed::Worker.default_queue_name = 'media'
Delayed::Worker.queue_attributes = {
  media: { priority: 10 },
  harvest: { priority: 0 }
}
Delayed::Worker.max_run_time = 7.days # Yes, really. We watch the long-running jobs pretty closely.
Delayed::Worker.max_attempts = 2

# TODO: You should really move these to a jobs folder.
HarvestJob = Struct.new(:resource_id) do
  def perform
    ActiveRecord::Base.connection.reconnect!
    Resource.find(resource_id).harvest
  end

  def queue_name
    'harvest'
  end

  def max_attempts
    1
  end

  def error(job, exception)
    Rails.logger.error("** HARVEST JOB ERROR: #{exception.message} TRACE: #{exception.backtrace.join("\n")}")
  end

  def after(_job)
    Rails.logger.info("Finished HarvestJob for Resource##{resource_id}")
    Resource.find(resource_id).unlock rescue nil
  end
end

ReHarvestJob = Struct.new(:resource_id) do
  def perform
    ActiveRecord::Base.connection.reconnect!
    Resource.find(resource_id).re_harvest
  end

  def queue_name
    'harvest'
  end

  def max_attempts
    1
  end

  def after(_job)
    Rails.logger.info("Finished ReHarvestJob for Resource##{resource_id}")
    Resource.find(resource_id).unlock rescue nil
  end
end

ResumeHarvestJob = Struct.new(:resource_id) do
  def perform
    ActiveRecord::Base.connection.reconnect!
    Resource.find(resource_id).resume
  end

  def queue_name
    'harvest'
  end

  def max_attempts
    1
  end

  def after(_job)
    Rails.logger.info("Finished ResumeHarvestJob for Resource##{resource_id}")
    Resource.find(resource_id).unlock rescue nil
  end
end

ReDownloadOpendataHarvestJob = Struct.new(:resource_id) do
  def perform
    ActiveRecord::Base.connection.reconnect!
    Resource.find(resource_id).re_download_opendata_and_harvest
  end

  def queue_name
    'harvest'
  end

  def max_attempts
    1
  end

  def after(_job)
    Rails.logger.info("Finished ReDownloadOpendataHarvestJob for Resource##{resource_id}")
    Resource.find(resource_id).unlock rescue nil
  end
end

DownloadMediumJob = Struct.new(:medium_id) do
  def perform
    ActiveRecord::Base.connection.reconnect!
    Medium.find(medium_id).download_and_prep
  end

  def queue_name
    'media'
  end

  def max_attempts
    1 # We handle this elsewhere.
  end
end

RemoveContentJob = Struct.new(:resource_id) do
  def perform
    ActiveRecord::Base.connection.reconnect!
    resource = Resource.find(resource_id)
    message = "!! REMOVING CONTENT for resource #{resource.name} (##{resource.id})"
    Rails.logger.warn(message)
    Delayed::Worker.logger.warn(message)
    resource.remove_content
    resource.harvests.each &:delete
    `echo "!! Reset log via RemoveContentJob on #{Time.now}" > #{resource.process_log_path}`
  end

  def queue_name
    'harvest'
  end
end
