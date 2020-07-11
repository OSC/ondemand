ENV['RAILS_ENV'] ||= 'test'
ENV['OOD_LOCALES_ROOT'] = Rails.root.join('config/locales').to_s
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
