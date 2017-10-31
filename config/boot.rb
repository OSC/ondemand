# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

# FIXME: move to bin/setup instead, and remove this
ENV['RAILS_RELATIVE_URL_ROOT'] = "/pun/sys/myjobs" if ENV['RAILS_ENV'] == 'production' && ENV['RAILS_RELATIVE_URL_ROOT'].nil?

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

# load dotenv files before "before_configuration" callback
require File.expand_path('../config_root', __FILE__)
ConfigRoot.load_dotenv_files
