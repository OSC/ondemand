# frozen_string_literal: true

require 'test_helper'

class OodAppTest < ActiveSupport::TestCase
  test 'version should return null when Configuration.hide_app_version? is true' do
    Configuration.stubs(:hide_app_version?).returns(true)
    under_test = OodApp.new RouterMock.new('test/fixtures/apps/ood_app/with_version')
    assert_nil under_test.version
  end

  test 'version should return application version when Configuration.hide_app_version? is false' do
    Configuration.stubs(:hide_app_version?).returns(false)
    under_test = OodApp.new RouterMock.new('test/fixtures/apps/ood_app/with_version')
    assert_equal '2.0.10', under_test.version
  end

  test 'version should return nil when application version is the unknown string' do
    Configuration.stubs(:hide_app_version?).returns(false)
    under_test = OodApp.new RouterMock.new('test/fixtures/apps/ood_app/with_unknown_version')
    assert_nil under_test.version
  end

  test 'version should handle application without a version' do
    Configuration.stubs(:hide_app_version?).returns(false)
    under_test = OodApp.new RouterMock.new('test/fixtures/apps/ood_app/no_version')
    under_test.stubs(:version_from_git).returns(nil)
    assert_nil under_test.version
  end

  class RouterMock
    def initialize(path)
      @app_path = Pathname.new(path)
    end

    def path
      @app_path
    end

    def name
      'name'
    end

    def owner
      'owner'
    end

    def type
      'type'
    end
  end
end
