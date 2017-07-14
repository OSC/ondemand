ENV['RAILS_ENV'] ||= 'test'
ENV['OOD_CLUSTERS'] ||= 'test/fixtures/config/clusters.d'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
end

require 'mocha/mini_test'
