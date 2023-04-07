# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
ENV['OOD_LOCALES_ROOT'] = Rails.root.join('config/locales').to_s

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'climate_control'
require 'timecop'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...

  UserDouble = Struct.new(:name, :groups)

  class BrokenAdapter < OodCore::Job::Adapter
    SUBMIT_ERR_MSG = 'this adapter cannot submit jobs'
    def submit(_)
      raise StandardError, SUBMIT_ERR_MSG
    end
  end

  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end

  def exit_success
    OpenStruct.new(:success? => true, :exitstatus => 0)
  end

  def exit_failure(exit_status=1)
    OpenStruct.new(:success? => false, :exitstatus => exit_status)
  end

  def stub_usr_router
    Configuration.stubs(:app_sharing_enabled?).returns(true)
    Configuration.stubs(:app_development_enabled?).returns(true)
    stub_user

    UsrRouter.stubs(:base_path).with(:owner => "me").returns(Pathname.new("test/fixtures/usr/me"))
    UsrRouter.stubs(:base_path).with(:owner => 'shared').returns(Pathname.new("test/fixtures/usr/shared"))
    UsrRouter.stubs(:base_path).with(:owner => 'cant_see').returns(Pathname.new("test/fixtures/usr/cant_see"))
    UsrRouter.stubs(:owners).returns(['me', 'shared', 'cant_see'])
  end

  def stub_user
    OodSupport::Process.stubs(:user).returns(UserDouble.new('me', ['me']))
    OodSupport::User.stubs(:new).returns(UserDouble.new('me', ['me']))
    Etc.stubs(:getlogin).returns('me')
  end

  def stub_sys_apps
    stub_clusters
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys_with_gateway_apps'))
  end

  def stub_clusters
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))
  end

  def setup_usr_fixtures
    FileUtils.chmod 0000, 'test/fixtures/usr/cant_see/'
  end

  def teardown_usr_fixtures
    FileUtils.chmod 0755, 'test/fixtures/usr/cant_see/'
  end

  def bc_ele_id(ele)
    "batch_connect_session_context_#{ele}"
  end

  def button_link?(text, link)
    find('.btn', text: text)
    has_link?(link)
  end

  def stub_user_configuration(user_configuration_overrides)
    ::Configuration.stubs(:config).returns(user_configuration_overrides)
    user_configuration = UserConfiguration.new
    ::Configuration.unstub(:config)

    UserConfiguration.stubs(:new).returns(user_configuration)

  end
end

require 'mocha/minitest'
