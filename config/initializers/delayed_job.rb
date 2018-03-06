Delayed::Worker.logger = Logger.new(Rails.root.join('log', 'delayed_job.log'))
Delayed::Worker.default_queue_name = 'media'
Delayed::Worker.queue_attributes = {
  media: { priority: 10 },
  harvest: { priority: 0 }
}
Delayed::Worker.max_run_time = 7.days # Yes, really. We watch the long-running jobs pretty closely.
Delayed::Worker.max_attempts = 2

# Because of https://github.com/collectiveidea/delayed_job_active_record/issues/63
Delayed::Backend::ActiveRecord.configure do |config|
  config.reserve_sql_strategy = :default_sql
end

# NOTE: If you add another one of these, you should really move them to a jobs folder.
HarvestJob = Struct.new(:resource_id) do
  def perform
    Resource.find(resource_id).harvest
  end

  def queue_name
    'harvest'
  end

  def max_attempts
    1
  end
end

ReHarvestJob = Struct.new(:resource_id) do
  def perform
    Resource.find(resource_id).re_harvest
  end

  def queue_name
    'harvest'
  end

  def max_attempts
    1
  end
end

ResumeHarvestJob = Struct.new(:resource_id) do
  def perform
    Resource.find(resource_id).resume
  end

  def queue_name
    'harvest'
  end

  def max_attempts
    1
  end
end
