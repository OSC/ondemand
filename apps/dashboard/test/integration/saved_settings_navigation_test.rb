# frozen_string_literal: true

require 'html_helper'
require 'test_helper'

class SavedSettingsNavigationTest < ActionDispatch::IntegrationTest
  def setup
    stub_sys_apps
  end

  test 'saved settings menu should not be rendered when OOD_BC_SAVED_SETTINGS is false' do
    with_modified_env({ OOD_BC_SAVED_SETTINGS: 'false' }) do
      stub_user_settings

      get batch_connect_setting_path(token: 'sys/bc_paraview', id: 'menu_name')
      assert_response :ok

      assert_select 'div#saved-settings-menu', 0
    end
  end

  test 'saved settings menu should be rendered when OOD_BC_SAVED_SETTINGS is true' do
    with_modified_env({ OOD_BC_SAVED_SETTINGS: 'true' }) do
      stub_user_settings

      expected_pages = [
        batch_connect_setting_path(token: 'sys/bc_paraview', id: 'menu_name'),
        batch_connect_sessions_path,
        new_batch_connect_session_context_path(token: 'sys/bc_paraview')
      ]

      expected_pages.each do |page_path|
        get page_path
        assert_response :ok

        assert_select 'div#saved-settings-menu'
      end
    end
  end

  test 'saved settings menu should render expected items' do
    with_modified_env({ OOD_BC_SAVED_SETTINGS: 'true' }) do
      stub_user_settings

      get batch_connect_sessions_path
      assert_response :ok

      assert_select 'div#saved-settings-menu'
      assert_equal 'Saved Settings', css_select('div#saved-settings-menu div.card-header').text.strip

      assert_equal 'Paraview', css_select('div#saved-settings-menu p.header').text.strip
      menu_links = css_select('div#saved-settings-menu div.saved-settings-list a.list-group-item-action')
      assert_equal 1, menu_links.size
      assert_equal 'menu_name', menu_links.first.text.strip
      assert_equal batch_connect_setting_path(token: 'sys/bc_paraview', id: 'menu_name'), menu_links.first['href']
    end
  end

  test 'saved settings menu should be empty message when no saved settings available' do
    with_modified_env({ OOD_BC_SAVED_SETTINGS: 'true' }) do
      Dir.mktmpdir do |dir|
        user_settings_file = "#{dir}/user_settings.yml"
        stub_user_settings(user_settings_file)

        get batch_connect_sessions_path
        assert_response :ok

        assert_select 'div#saved-settings-menu'
        assert_equal 'Saved Settings', css_select('div#saved-settings-menu div.card-header').text.strip
        assert_equal 'You have no saved settings.', css_select('div#saved-settings-menu span.list-group-item-action').text.strip
      end
    end
  end

  def stub_user_settings(file = nil)
    file = "#{Rails.root}/test/fixtures/file_output/user_settings/saved_settings_menu.yml" if file.blank?
    Configuration.stubs(:user_settings_file).returns(file)
  end
end
