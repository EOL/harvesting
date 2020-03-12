class LogRotateJob < ApplicationJob
  queue_as :default
 
  def perform
    `logrotate #{Rails.root.join('config', 'logrotate.conf')}`
  end
end
