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
    Resource.find(resource_id).unlock rescue nil
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

  def after(_job)
    Resource.find(resource_id).unlock rescue nil
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

  def after(_job)
    Resource.find(resource_id).unlock rescue nil
  end
end

ReDownloadOpendataHarvestJob = Struct.new(:resource_id) do
  def perform
    Resource.find(resource_id).re_download_opendata_and_harvest
  end

  def queue_name
    'harvest'
  end

  def max_attempts
    1
  end

  def after(_job)
    Resource.find(resource_id).unlock rescue nil
  end
end

DownloadMediumJob = Struct.new(:medium_id) do
  def perform
    Medium.find(medium_id).download_and_prep
  end

  def queue_name
    'media'
  end

  def max_attempts
    1 # We handle this elsewhere.
  end
end
