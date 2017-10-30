ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

# TODO: File.basename(File.expand_path('../../', __FILE__)) == "dashboard"
# assume /pun/sys since core app... but for other apps, a solution that
# determines what app type could be a useful alternative...
# TODO: could just drop this and add it to the bin/setup instead (that is probably best)
ENV['RAILS_RELATIVE_URL_ROOT'] = "/pun/sys/dashboard" if ENV['RAILS_ENV'] == 'production' && ENV['RAILS_RELATIVE_URL_ROOT'].nil?

require 'bundler/setup' # Set up gems listed in the Gemfile.
