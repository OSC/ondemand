# frozen_string_literal: true

require 'application_system_test_case'

# Exercise log draining and recovery against an actual Chrome session.
class BrowserSessionCleanupSystemTest < ApplicationSystemTestCase
  # Run an intentional failure manually, retaining Rails' real teardown hook.
  class Example < Minitest::Test
    include ActionDispatch::SystemTesting::TestHelpers::SetupAndTeardown
    include BrowserSessionCleanup

    attr_reader :body_calls

    def initialize(body)
      super('exercise')
      @body = body
      @body_calls = 0
    end

    def exercise
      @body_calls += 1
      @body.call
    end

    # A closed browser cannot capture an image; inspect the original result instead.
    def take_failed_screenshot; end
  end

  test 'console draining preserves the running browser' do
    visit files_url(Rails.root.to_s)
    browser = page.driver.browser
    window = browser.window_handle
    marker = 'browser-session-cleanup-console-canary'
    page.execute_script("console.error('#{marker}')")

    assert(clear_browser_logs.any? { |entry| entry.message.include?(marker) })
    assert_same browser, page.driver.browser
    assert_equal window, browser.window_handle
    assert_empty(browser.logs.get(:browser).select { |entry| entry.message.include?(marker) })
  end

  test 'a closed Chrome fails its example and the following example can navigate' do
    visit files_url(Rails.root.to_s)
    original_browser = page.driver.browser
    crashing = Example.new(lambda do
      original_browser.execute_cdp('Browser.close')
      original_browser.current_url
    end)
    failed = nil
    _output, diagnostics = capture_io { failed = crashing.run }

    refute failed.passed?
    assert_equal 1, crashing.body_calls
    assert_kind_of Selenium::WebDriver::Error::WebDriverError, failed.failures.first.error
    assert_includes diagnostics, 'discarding dead browser'

    following = Example.new(lambda do
      visit files_url(Rails.root.to_s)
      assert_selector '#directory-contents tbody a', exact_text: 'app'
    end)
    result = following.run

    assert result.passed?, result.failures.map(&:message).join("\n")
    assert_equal 1, following.body_calls
    refute_same original_browser, page.driver.browser
  end
end
