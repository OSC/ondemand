# frozen_string_literal: true

# Run separately: bundle exec ruby -Itest test/diagnostics/browser_session_cleanup.rb
# Deliberately closes Chrome; this file is excluded from normal *_test.rb discovery.
require 'application_system_test_case'

# Prove real-browser recovery in a dedicated process that cannot poison CI tests.
class BrowserSessionCleanupDiagnosticTest < ApplicationSystemTestCase
  # Retain Rails teardown while observing the intentional child failure.
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

    def take_failed_screenshot; end
  end

  test 'a closed Chrome fails once and the following example can navigate' do
    visit files_url(Rails.root.to_s)
    original_browser = page.driver.browser
    crashing = Example.new(lambda do
      original_browser.execute_cdp('Browser.close')
      Selenium::WebDriver::Wait.new(timeout: 10).until do
        original_browser.current_url
        false
      end
    end)
    failed = nil
    _output, diagnostics = capture_io { failed = crashing.run }

    refute failed.passed?
    assert_equal 1, crashing.body_calls
    assert_kind_of Selenium::WebDriver::Error::WebDriverError, failed.failures.first.error
    assert_includes diagnostics, 'discarding browser session'

    following = Example.new(lambda do
      visit files_url(Rails.root.to_s)
      assert_selector '#directory-contents tbody a', exact_text: 'app'
    end)
    result = following.run

    assert result.passed?, result.failures.map(&:message).join("\n")
    assert_equal 1, following.body_calls
    refute_same original_browser, page.driver.browser
  ensure
    discard_browser('diagnostic cleanup')
  end
end
