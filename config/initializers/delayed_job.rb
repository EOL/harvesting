Delayed::Worker.logger = Logger.new(Rails.root.join('log', 'delayed_job.log'))
Delayed::Worker.default_queue_name = 'media'
Delayed::Worker.queue_attributes = {
  media: { priority: 10 },
  harvest: { priority: 0 }
}
Delayed::Worker.max_run_time = 7.days # Yes, really. We watch the long-running jobs pretty closely.
Delayed::Worker.max_attempts = 2

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
