ENV['RAILS_ENV'] ||= 'test'
ENV['OOD_LOCALES_ROOT'] = Rails.root.join('config/locales').to_s
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
end

require 'mocha/minitest'
