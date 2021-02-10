source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem 'rails', '5.2.4.1'

# "Interal" EOL gems:
gem 'eol_terms', git: 'https://github.com/EOL/eol_terms.git'

# Because we are going to create many, many records!
gem 'activerecord-import', '~> 1'
# Used when parsing URLs (was included in Rails 4, but not 5)
gem 'addressable', '~> 2'
# Acts As List simplifies ordered lists of models:
gem 'acts_as_list', '~> 1'
# Parse Excel files:
gem 'creek', '~> 2'
# Cron jobs:
gem 'crono', '~> 1' # .1
# Required to run bin/delayed_job:
gem 'daemons', '~> 1'
# Dalli store:
gem 'dalli', '~> 2'
# Background jobs:
gem 'delayed_job', '~> 4.1.8'
gem 'delayed_job_active_record', '~> 4'
# Store users securely:
gem 'devise', '~> 4' # .7'
# Enums with simple_form:
gem 'enum_help', '~> 0'
# Because ERB is just plain silly compared to Haml:
gem 'haml-rails', '~> 5'
# To aid in converting language codes:
gem 'iso-639', '~> 0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2'
# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4'
# Pagination!
gem 'kaminari', '~> 1'
# Helps lock processes safely (maybe not REALLY needed for our purposes, but I feel safer with it):
gem 'lockfile', '~> 2'
# QUIET PLEASE MAKE IT STOP:
gem 'lograge', '~> 0'
# Use mysql as the database for Active Record
gem 'mysql2', '0.5' # .3'
# Used in parsing XML for new resources:
gem 'nokogiri', '~> 1'
# Debugging:
gem 'pry-rails', '~> 0'
# Authorization:
gem 'pundit', '~> 2'
# Image resizing and manipulation:
gem 'rmagick', '~> 4'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 2'
# ElasticSearch:
gem 'searchkick', '~> 4' # Depends on elasticsearch, which needs to be running our version.
gem 'elasticsearch', '~> 6' # Needs to be in sync with the version of ES you are running.
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 1'
# Making forms simpler:
gem 'simple_form', '~> 5'
# JS runtime
gem 'therubyracer', '0' # .12.3'
# Turbolinks makes following links in your web application faster. Read more:
# https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 4'
# Find (in order to remove) emoji in strings:
gem 'unicode-emoji', '~> 2'
# Use Unicorn as the app server
gem 'unicorn', '~> 5'
gem 'unicorn-worker-killer', '~> 0'
# Our own crontab. Read https://github.com/javan/whenever foe details.
gem 'whenever', '~> 1', :require => false

group :development, :test do
  # Yes, pry is kinda redundant with byebug, but it doesnt' do stepping, sooo:
  gem 'byebug'
  gem 'factory_bot_rails', '~> 5'
  # Testing framework:
  gem 'rspec-rails', '~> 3'
  gem 'solargraph', '~> 0'
end

group :development do
  # Required after Rails 5 upgrade:
  gem 'listen', '~> 3'
  # For benchmarking queries:
  gem 'meta_request', '~> 0'
  # Spring speeds up development by keeping your application running in the background. Read more:
  # https://github.com/rails/spring
  gem 'spring', '~> 2'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3'
end
