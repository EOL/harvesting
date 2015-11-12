# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Harvester::Application.initialize!

Rails.configuration.site_id = ENV["SITE_ID"] || 1
