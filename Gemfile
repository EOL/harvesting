source "https://rubygems.org"

# Because we are going to create many, many records!
gem 'activerecord-import'
# Acts As List simplifies ordered lists of models:
gem 'acts_as_list'

# Parse Excel files:
gem "creek"

# Required to run bin/delayed_job:
gem 'daemons'
# Background jobs:
gem 'delayed_job_active_record'
# Dalli store:
gem 'dalli'

# Because ERB is just plain silly compared to Haml:
gem 'haml-rails'

# To aid in converting language codes:
gem 'iso-639'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder"
# Use jquery as the JavaScript library
gem "jquery-rails"

# Pagination!
gem 'kaminari'

# Use mysql as the database for Active Record
gem "mysql2"

# Debugging:
gem 'pry-rails'

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", "4.2.10"
# Image resizing and manipulation:
gem 'rmagick'

# Use SCSS for stylesheets
gem "sass-rails"
# ElasticSearch:
gem 'searchkick'
# bundle exec rake doc:rails generates the API under doc/api.
gem "sdoc"

# Making forms simpler:
gem "simple_form"

# JS runtime
gem 'therubyracer'

# Turbolinks makes following links in your web application faster. Read more:
# https://github.com/rails/turbolinks
gem "turbolinks"

# Use Uglifier as compressor for JavaScript assets
gem "uglifier"

group :development, :test do
  # Yes, pry is kinda redundant with byebug, but it doesnt' do stepping, sooo:
  gem 'byebug'

  gem "factory_bot_rails"

  # Testing framework:
  gem "rspec-rails"
end

group :development do
  # For benchmarking queries:
  gem 'meta_request'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console"
end
