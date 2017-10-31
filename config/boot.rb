# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

# load dotenv files before "before_configuration" callback
require File.expand_path('../config_root', __FILE__)
ConfigRoot.load_dotenv_files
