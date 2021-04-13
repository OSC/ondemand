ENV['RAILS_ENV'] ||= 'test'
ENV['OOD_LOCALES_ROOT'] = Rails.root.join('config/locales').to_s

module Dashboard
  class Application < Rails::Application
    config.paths["app/views"].unshift "test/fixtures/config/views"
  end
end

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'climate_control'
require 'timecop'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...

  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end
end

require 'mocha/minitest'
