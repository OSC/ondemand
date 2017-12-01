# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# load dotenv files before "before_configuration" callback
require File.expand_path('../configuration', __FILE__)

# global instance to access and use
AppConfig = Configuration.new
AppConfig.load_dotenv_files

# set defaults to address OodAppkit.dataroot issue
ENV['OOD_DATAROOT'] = AppConfig.dataroot.to_s
ENV['DATABASE_PATH'] = AppConfig.database_path.to_s
