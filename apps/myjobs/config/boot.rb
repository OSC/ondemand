ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# TODO: we remove this once we upgrade to Rails 7.1
require 'logger'

require 'bundler/setup' # Set up gems listed in the Gemfile.

# load dotenv files before "before_configuration" callback
require_relative 'configuration_singleton'

# global instance to access and use
Configuration = ConfigurationSingleton.new
Configuration.load_dotenv_files

# set defaults to address OodAppkit.dataroot issue
ENV['OOD_DATAROOT'] = Configuration.dataroot.to_s
