class AddQueueIndexToDelayedJobs < ActiveRecord::Migration[4.2]
  def change
    add_index :delayed_jobs, :queue
  end
end
