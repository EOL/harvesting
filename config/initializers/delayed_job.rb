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

HarvestingBaseJob = Struct.new(:resource_id) do
  def perform
    message = "!! Harvesting base job called perform for resource #{resource.name} (##{resource.id}), NO ACTION TAKEN"
    Rails.logger.warn(message)
    Delayed::Worker.logger.warn(message)
  end

  def queue_name
    'harvest'
  end

  def max_attempts
    1 # We handle this elsewhere.
  end
end
