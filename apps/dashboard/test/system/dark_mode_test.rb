# frozen_string_literal: true

require 'application_system_test_case'
require 'timeout'

class DarkModeTest < ApplicationSystemTestCase
  def setup
    stub_sys_apps
    stub_user
    stub_clusters
    stub_sinfo
  end

  test 'safe viewing toggle switches theme and persists in user settings' do
    Dir.mktmpdir do |dir|
      settings_file = "#{dir}/settings.yml"
      Configuration.stubs(:user_settings_file).returns(settings_file)

      visit root_path

      toggle = find('#ood_dark_mode_toggle')
      assert_equal 'false', toggle['aria-pressed']
      assert_equal 'Light', find('.ood-theme-toggle__label', visible: :all).text
      assert page.evaluate_script("document.documentElement.getAttribute('data-bs-theme')").nil?

      toggle.click
      assert_equal 'true', toggle['aria-pressed']
      assert_equal 'Dark', find('.ood-theme-toggle__label', visible: :all).text
      assert_equal 'dark', page.evaluate_script("document.documentElement.getAttribute('data-bs-theme')")
      assert page.evaluate_script("document.documentElement.classList.contains('ood-safe-viewing')")

      # Wait for settings POST to finish writing UserSettingStore.
      Timeout.timeout(5) do
        sleep 0.1 until File.exist?(settings_file) && YAML.safe_load(File.read(settings_file)).to_h['safe_viewing'] == true
      end

      visit root_path
      assert_equal 'true', find('#ood_dark_mode_toggle')['aria-pressed']
      assert_equal 'dark', page.evaluate_script("document.documentElement.getAttribute('data-bs-theme')")
      assert_selector 'html.ood-safe-viewing[data-bs-theme="dark"]', visible: :all

      find('#ood_dark_mode_toggle').click
      assert_equal 'false', find('#ood_dark_mode_toggle')['aria-pressed']
      assert page.evaluate_script("document.documentElement.getAttribute('data-bs-theme')").nil?

      Timeout.timeout(5) do
        sleep 0.1 until YAML.safe_load(File.read(settings_file)).to_h['safe_viewing'] == false
      end

      visit root_path
      assert_equal 'false', find('#ood_dark_mode_toggle')['aria-pressed']
      assert page.evaluate_script("document.documentElement.getAttribute('data-bs-theme')").nil?
    end
  end

  test 'safe viewing toggle is hidden when disabled in configuration' do
    Configuration.stubs(:dark_mode_enabled?).returns(false)

    visit root_path

    assert_no_selector '#ood_dark_mode_toggle'
  end
end
