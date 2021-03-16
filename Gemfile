source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem 'rails', '5.2.4.4'

# "Interal" EOL gems:
gem 'eol_terms', git: 'https://github.com/EOL/eol_terms.git', branch: 'main'

# Because we are going to create many, many records!
gem 'activerecord-import', '~> 1.0'
# Used when parsing URLs (was included in Rails 4, but not 5)
gem 'addressable', '~> 2.7'
# Acts As List simplifies ordered lists of models:
gem 'acts_as_list', '~> 1.0'
# Parse Excel files:
gem 'creek', '~> 2.5'
# Cron jobs:
gem 'crono', '~> 1.1'
# Required to run bin/delayed_job:
gem 'daemons', '~> 1.3'
# mem_cache_store needs this:
gem 'dalli', '~> 2.7'
# Background jobs:
gem 'delayed_job', '~> 4.1.9'
gem 'delayed_job_active_record', '~> 4.1'
# Store users securely:
gem 'devise', '~> 4.7'
# Enums with simple_form:
gem 'enum_help', '~> 0.0'
# Because ERB is just plain silly compared to Haml:
gem 'haml-rails', '~> 2.0'
# To aid in converting language codes:
gem 'iso-639', '~> 0.3'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.11'
# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.3'
# Pagination!
gem 'kaminari', '~> 1.2'
# Helps lock processes safely (maybe not REALLY needed for our purposes, but I feel safer with it):
gem 'lockfile', '~> 2.1'
# QUIET PLEASE MAKE IT STOP:
gem 'lograge', '~> 0.11'
# Use mysql as the database for Active Record
gem 'mysql2', '0.5.3'
# Used in parsing XML for new resources:
gem 'nokogiri', '~> 1.11'
# Debugging:
gem 'pry-rails', '~> 0.3'
# Authorization:
gem 'pundit', '~> 2.1'
# Image resizing and manipulation:
gem 'rmagick', '~> 4.2'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0'
# ElasticSearch:
gem 'searchkick', '~> 4.4' # Depends on elasticsearch, which needs to be running our version.
gem 'elasticsearch', '~> 6.8' # Needs to be in sync with the version of ES you are running.
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 1.1'
# Making forms simpler:
gem 'simple_form', '~> 5.1'
# Turbolinks makes following links in your web application faster. Read more:
# https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5.2'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 4.2'
# Find (in order to remove) emoji in strings:
gem 'emoji_regex', '~> 3.2'
# Use Unicorn as the app server
gem 'unicorn', '~> 5.8'
gem 'unicorn-worker-killer', '~> 0.4'
# Our own crontab. Read https://github.com/javan/whenever foe details.
gem 'whenever', '~> 1.0', require: false

group :development, :test do
  # Yes, pry is kinda redundant with byebug, but it doesnt' do stepping, sooo:
  gem 'byebug', '~> 11.1'
  gem 'factory_bot_rails', '~> 5.2'
  # Testing framework:
  gem 'rspec-rails', '~> 3.9'
  gem 'solargraph', '~> 0.40'
end

group :development do
  # Required after Rails 5 upgrade:
  gem 'listen', '~> 3.4'
  # For benchmarking queries:
  gem 'meta_request', '~> 0.7'
  # Spring speeds up development by keeping your application running in the background. Read more:
  # https://github.com/rails/spring
  gem 'spring', '~> 2.1'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.7'
end
