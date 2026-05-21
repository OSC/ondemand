# frozen_string_literal: true

require 'application_system_test_case'

class DarkModeTest < ApplicationSystemTestCase
  def setup
    stub_sys_apps
    stub_user
    stub_clusters
    stub_sinfo
  end

  test 'safe viewing toggle switches theme and persists' do
    visit root_path

    toggle = find('#ood_dark_mode_toggle')
    assert_equal 'false', toggle['aria-pressed']
    assert page.evaluate_script("document.documentElement.getAttribute('data-bs-theme')").nil?

    toggle.click
    assert_equal 'true', toggle['aria-pressed']
    assert_equal 'dark', page.evaluate_script("document.documentElement.getAttribute('data-bs-theme')")
    assert page.evaluate_script("document.documentElement.classList.contains('ood-safe-viewing')")

    visit root_path
    assert_equal 'true', find('#ood_dark_mode_toggle')['aria-pressed']
    assert_equal 'dark', page.evaluate_script("document.documentElement.getAttribute('data-bs-theme')")

    find('#ood_dark_mode_toggle').click
    assert_equal 'false', find('#ood_dark_mode_toggle')['aria-pressed']
    assert page.evaluate_script("document.documentElement.getAttribute('data-bs-theme')").nil?
  end

  test 'safe viewing toggle is hidden when disabled in configuration' do
    Configuration.stubs(:dark_mode_enabled?).returns(false)

    visit root_path

    assert_no_selector '#ood_dark_mode_toggle'
  end
end
