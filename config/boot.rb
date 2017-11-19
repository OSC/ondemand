# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# load dotenv files before "before_configuration" callback
require File.expand_path('../configuration', __FILE__)
AppConfig.load_dotenv_files
