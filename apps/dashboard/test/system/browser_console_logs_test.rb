# frozen_string_literal: true

require 'application_system_test_case'
require_relative 'files_test'
require_relative 'remote_files_test'

# Exercise the actual Files hooks so restoring a per-example quit fails here.
class BrowserConsoleLogsTest < ApplicationSystemTestCase
  [FilesTest, RemoteFilesTest].each do |test_class|
    define_method("test_#{test_class.name}_setup_drains_logs_without_replacing_chrome") do
      visit files_url(Rails.root.to_s)
      browser = page.driver.browser
      window = browser.window_handle
      marker = "browser-console-drain-#{test_class.name}"
      page.execute_script("console.error('#{marker}')")
      assert(browser.logs.get(:browser).any? { |entry| entry.message.include?(marker) })
      page.execute_script("console.error('#{marker}')")

      test_class.new('unused').setup

      assert_same browser, page.driver.browser
      assert_equal window, browser.window_handle
      assert_empty(browser.logs.get(:browser).select { |entry| entry.message.include?(marker) })
    end
  end
end
