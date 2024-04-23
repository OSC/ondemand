# frozen_string_literal: true

require 'html_helper'
require 'test_helper'

class SavedSettingsControllerTest < ActionDispatch::IntegrationTest
  def setup
    stub_sys_apps
    @test_user_settings = TestUserSettings.new
  end

  test 'should display saved settings with action buttons' do
    Dir.mktmpdir do |dir|
      user_settings_file = "#{dir}/user_settings.yml"
      stub_user_settings(user_settings_file)
      @test_user_settings.save_settings('sys/bc_paraview', 'display')
      assert_not_nil @test_user_settings.read_settings('sys/bc_paraview', 'display')

      get batch_connect_setting_path(token: 'sys/bc_paraview', id: 'display')
      assert_response :ok

      assert_select 'div#settings-card'
      assert_equal 'display', css_select('div#settings-card div.card-heading span#settings-name').text.strip
      assert_equal 'Paraview', css_select('div#settings-card p#settings-app').text.strip

      # display the saved settings actions buttons
      assert_select 'div.card-header #edit-saved-settings-button', 1
      assert_select 'div.card-header #launch-saved-settings-button', 1
      assert_select 'div.card-body #delete-saved-settings-button', 1

      # display the saved settings values
      settings_items = css_select('div#settings-card div.card-body p')
      assert_equal 4, settings_items.size
      assert_equal 'Cluster:', settings_items[0].at('strong').text.strip
      assert_equal 'quick', settings_items[0].at('span').text.strip
      assert_equal 'Number of hours:', settings_items[1].at('strong').text.strip
      assert_equal '4', settings_items[1].at('span').text.strip
      assert_equal 'Account:', settings_items[2].at('strong').text.strip
      assert_equal 'abc123', settings_items[2].at('span').text.strip
      assert_equal 'Resolution:', settings_items[3].at('strong').text.strip
      assert_equal '500x600', settings_items[3].at('span').text.strip
    end
  end

  test 'should delete saved settings' do
    Dir.mktmpdir do |dir|
      user_settings_file = "#{dir}/user_settings.yml"
      stub_user_settings(user_settings_file)
      @test_user_settings.save_settings('sys/bc_paraview', 'delete')
      assert_not_nil @test_user_settings.read_settings('sys/bc_paraview', 'delete')

      # Verify that settings are available.
      get batch_connect_setting_path(token: 'sys/bc_paraview', id: 'delete')
      assert_response :ok
      assert_select 'div.card-body #delete-saved-settings-button', 1

      # Delete settings
      token = css_select("button#delete-saved-settings-button ~ input[type='hidden'][name='authenticity_token']").first['value']
      headers = { 'X-CSRF-Token' => token }
      delete batch_connect_setting_path(token: 'sys/bc_paraview', id: 'delete'), headers: headers
      follow_redirect!
      assert_response :success
      assert_equal new_batch_connect_session_context_path(token: 'sys/bc_paraview'), path
      # Displays success message
      assert_select "div.alert-success[role='alert']", 1
      # verify settings are deleted
      assert_nil @test_user_settings.read_settings('sys/bc_paraview', 'delete')
    end
  end

  test 'display settings with invalid name should redirect to BatchConnect Context page' do
    stub_user_settings

    get batch_connect_setting_path(token: 'sys/bc_paraview', id: 'invalid')
    follow_redirect!
    assert_response :success
    assert_equal new_batch_connect_session_context_path(token: 'sys/bc_paraview'), path
    # Displays error message
    # There should be 3 alert-danger divs
    # js placeholder
    # browser warning
    # saved settings not found
    assert_select "div.alert-danger[role='alert']", 3
    assert_select "div.alert-danger[role='alert']" do |elements|
      assert_match(/Selected saved settings not found/, elements[2].text)
    end
  end

  def stub_user_settings(file = nil)
    file = "#{Rails.root}/test/fixtures/file_output/user_settings/saved_settings_menu.yml" if file.blank?
    Configuration.stubs(:user_settings_file).returns(file)
  end

  class TestUserSettings
    include UserSettingStore
    def save_settings(app_token, name, key_values = nil)
      if key_values.nil?
        key_values = {
          cluster:           'quick',
          bc_num_hours:      '4',
          bc_account:        'abc123',
          bc_vnc_resolution: '500x600'
        }
      end
      save_bc_template(app_token, name, key_values)
    end

    def read_settings(app_token, name)
      @user_settings = read_user_settings
      bc_templates(app_token)[name.to_sym]
    end
  end
end
