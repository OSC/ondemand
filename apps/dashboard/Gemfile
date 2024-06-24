source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '7.0.8.1'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', group: :doc, require: false

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry'
  gem 'timecop', '~> 0.9'
end

group :test do
  gem "capybara"
  # lock selenium as it doesn't work on ubuntu 22.04
  # https://github.com/SeleniumHQ/selenium/issues/11291
  gem "selenium-webdriver", '4.5.0'
  gem "webrick"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  # gem 'web-console', '~> 2.0'
end

# lock nokogiri & net-imap to versions that are compatible with ruby 2.7.0
# Ubuntu 20.04 uses.
gem 'nokogiri', '~> 1.15', '< 1.16'
gem 'net-imap', '~> 0.3', '< 0.4'

# Extra third-party gems
gem 'dotenv-rails', '~> 2.1'
gem 'redcarpet', '~> 3.3'
gem 'browser', '~> 2.2'
gem 'addressable', '~> 2.4'
gem 'bootstrap_form', '5.0'
gem 'mocha', '~> 2.1', group: :test
gem 'autoprefixer-rails', '~> 10.2.5'
gem 'dotiw'
gem 'local_time', '~> 1.0.3'
gem 'zip_kit', '~> 6.2'
gem 'rss', '~> 0.2'
gem 'climate_control', '~> 0.2'

gem 'jsbundling-rails', '~> 1.0'
gem 'cssbundling-rails', '~> 1.1'
gem 'turbo-rails', '~> 2.0'

# should upgrade to propshaft - only have an issue with fontawesome icons
gem 'sprockets-rails', '>= 2.0.0'

# OOD specific gems
gem 'ood_support', '~> 0.0.2'
gem 'ood_appkit', '~> 2.1.0'
gem 'ood_core', '~> 0.24'
gem 'pbs', '~> 2.2.1'
gem 'rest-client', '~> 2.0'

# gems to include in ondemand-gems repo for status apps to use
gem "sinatra", require: false
gem "sinatra-contrib", require: false
gem "erubi", require: false
gem "dalli", require: false

