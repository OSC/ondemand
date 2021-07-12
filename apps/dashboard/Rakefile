# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# ensure local .env.* files are ignored during testing.
if (ARGV.first.nil? || ARGV.first.to_s == "test") && ENV['RAILS_ENV'].nil?
  ENV['RAILS_ENV'] = "test"
end

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks
