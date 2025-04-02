# frozen_string_literal: true

require 'test_helper'

class SettingsControllerTest < ActionDispatch::IntegrationTest
  def setup
    # lot's of setup here to get a valid csrf-token
    get root_path
    assert :success

    doc = Nokogiri::XML(@response.body)
    @token = doc.xpath("/html/head/meta[@name='csrf-token']/@content").to_s
    @headers = { 'X-CSRF-Token' => @token }
  end

  test 'should save and override profile settings when posting profile' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
      data = { settings: {} }

      data[:settings][:profile] = 'first_profile'
      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_equal 'first_profile', TestUserSettings.new.user_settings[:profile]

      data[:settings][:profile] = 'override_profile'
      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_equal 'override_profile', TestUserSettings.new.user_settings[:profile]
    end
  end

  test 'should allow empty or nil profile settings when posting profile' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
      data = { settings: {} }

      data[:settings][:profile] = ''
      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_equal '', TestUserSettings.new.user_settings[:profile]

      data[:settings][:profile] = nil
      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_nil TestUserSettings.new.user_settings[:profile]
    end
  end

  test 'should save announcement settings and allow multiple announcements when posting announcement' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
      data = { settings: {} }

      value =  Time.now.localtime.strftime('%Y-%m-%d %H:%M:%S')
      data[:settings] = { announcements: { 'announcement_id' => value } }
      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_equal value, TestUserSettings.new.user_settings[:announcements][:announcement_id]

      data[:settings] = { announcements: { 'other_announcement_id' => value } }
      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_equal value, TestUserSettings.new.user_settings[:announcements][:announcement_id]
      assert_equal value, TestUserSettings.new.user_settings[:announcements][:other_announcement_id]
    end
  end

  test 'should not save user_settings when no data' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
      data = { settings: {} }

      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_empty TestUserSettings.new.user_settings
    end
  end

  test 'should not save user_settings when parameters are outside the settings namespace' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
      data = { profile: 'root_value' }

      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_empty TestUserSettings.new.user_settings
    end
  end

  test 'should not save user_settings when parameters are not in the allowed list' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
      data = { settings: { not_allowed: 'root_value' } }

      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_empty TestUserSettings.new.user_settings
    end
  end

  class TestUserSettings
    include UserSettingStore
  end
end
