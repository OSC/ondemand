# favor tmp/node_modules/yarn/bin/yarnpkg
ENV['PATH'] = File.join(File.expand_path("../../",  __FILE__), 'tmp', 'node_modules', 'yarn', 'bin') + ":" + ENV['PATH'].to_s

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# load dotenv files before "before_configuration" callback
require File.expand_path('../configuration_singleton', __FILE__)

# global instance to access and use
Configuration = ConfigurationSingleton.new
Configuration.load_dotenv_files

# set defaults to address OodAppkit.dataroot issue
ENV['OOD_DATAROOT'] = Configuration.dataroot.to_s

# Rails 5.2.3 suggests adding bootsnap (https://github.com/Shopify/bootsnap)
# which writes to /tmp as it does not appear to write to a user-namespaced
# location and it does not clean up after itself, bootsnap seems like a poor 
# fit for OnDemand, and I am not including it at this time.
# require 'bootsnap/setup' # Speed up boot time by caching expensive operations.