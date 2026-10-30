# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/mock'
require 'mocha/minitest'
require 'capybara'
require 'capybara/selenium/driver'
require 'action_dispatch/system_testing/test_helpers/setup_and_teardown'
require_relative '../support/browser_session_cleanup'

# Inject faults through real Capybara sessions and Rails teardown hooks.
class BrowserSessionCleanupTest < Minitest::Test
  # Keep intentional child failures available for assertions by the parent test.
  class Example < Minitest::Test
    include ActionDispatch::SystemTesting::TestHelpers::SetupAndTeardown
    include BrowserSessionCleanup

    def initialize(body: nil, setup: nil, screenshot: nil)
      super('exercise')
      @body = body
      @setup = setup
      @screenshot = screenshot
    end

    def setup
      @setup&.call
    end

    def exercise
      @body&.call
    end

    def take_failed_screenshot
      @screenshot&.call unless passed?
    end
  end

  def setup
    Capybara.register_driver(:browser_cleanup_test) do |app|
      Capybara::Selenium::Driver.new(app, browser: :chrome)
    end
    @session = Capybara::Session.new(:browser_cleanup_test)
    @driver = @session.driver
    Capybara.stubs(:current_session).returns(@session)
  end

  # Inject a native browser at the Selenium boundary without launching Chrome.
  def activate_browser(touched: true)
    browser = stub('native browser', navigate: stub(to: nil), quit: nil, window_handles: ['window'])
    @driver.instance_variable_set(:@browser, browser)
    @session.visit('http://example.test') if touched
    browser
  end

  def run_example(**options)
    result = nil
    _stdout, output = capture_io do
      Capybara.stub(:reset_sessions!, -> { @session.reset! }) { result = Example.new(**options).run }
    end
    [result, output]
  end

  # Recovery must retain the failure and leave a fresh, unstarted driver.
  def assert_discarded(error, reason, **options)
    result, output = run_example(**options)

    assert_equal 1, result.failures.size
    assert_same error, result.failures.first.error
    refute_same @driver, @session.driver
    assert_nil @session.driver.instance_variable_get(:@browser)
    assert_includes output, reason
  end

  def test_healthy_teardown_keeps_the_browser
    browser = activate_browser
    @driver.stubs(:reset!)
    browser.expects(:quit).never

    result, output = run_example

    assert result.passed?
    assert_same @driver, @session.driver
    assert_empty output
  end

  def test_unstarted_session_does_not_start_chrome
    Selenium::WebDriver.expects(:for).never
    Capybara.expects(:current_session).never

    result, = run_example

    assert result.passed?
    assert_nil @driver.instance_variable_get(:@browser)
    assert_same @driver, @session.driver
  end

  [Selenium::WebDriver::Error::NoSuchWindowError, Selenium::WebDriver::Error::InvalidArgumentError,
   Net::ReadTimeout, EOFError].each do |type|
    define_method("test_failed_reset_#{type.name.split('::').last}_discards_the_session") do
      browser = activate_browser
      error = type.new('reset could not establish isolation')
      @driver.stubs(:reset!).raises(error)
      browser.expects(:quit).once

      assert_discarded(error, 'session teardown did not complete')
    end
  end

  {
    'invalid_session' => [Selenium::WebDriver::Error::InvalidSessionIdError, 'invalid session id'],
    'closed_window'   => [Selenium::WebDriver::Error::NoSuchWindowError, 'target window already closed'],
    'page_crash'      => [
      Selenium::WebDriver::Error::UnknownError, 'unknown error: session deleted because of page crash'
    ],
    'tab_crash'       => [Selenium::WebDriver::Error::UnknownError, 'tab crashed'],
    'disconnect'      => [
      Selenium::WebDriver::Error::UnknownError,
      "unknown error: renderer command failed\nfrom disconnected: not connected to DevTools"
    ],
    'unreachable'     => [
      Selenium::WebDriver::Error::UnknownError,
      "unknown error: renderer command failed\r\nfrom unknown error: chrome not reachable"
    ]
  }.each do |label, (type, message)|
    define_method("test_recorded_#{label}_is_released_when_reset_does_not_raise") do
      activate_browser(touched: false).expects(:quit).once
      error = type.new(message)

      assert_discarded(error, 'unusable browser context', setup: -> { raise error })
    end
  end

  [
    'unknown error: script output mentioned disconnected: not connected to DevTools',
    "unknown error: script failed\nscript output: from disconnected: not connected to DevTools"
  ].each_with_index do |message, index|
    define_method("test_disconnect_prose_#{index}_does_not_release_a_healthy_session") do
      browser = activate_browser(touched: false)
      browser.expects(:quit).never
      error = Selenium::WebDriver::Error::UnknownError.new(message)

      result, output = run_example(setup: -> { raise error })

      assert_same error, result.failures.first.error
      assert_same @driver, @session.driver
      assert_empty output
    end
  end

  [Selenium::WebDriver::Error::ElementNotInteractableError, EOFError].each do |type|
    define_method("test_body_#{type.name.split('::').last}_with_successful_reset_keeps_browser") do
      browser = activate_browser
      @driver.stubs(:reset!)
      browser.expects(:quit).never
      error = type.new('ordinary test or application error')

      result, output = run_example(body: -> { raise error })

      assert_same error, result.failures.first.error
      assert_same @driver, @session.driver
      assert_empty output
    end
  end

  [Errno::ECONNRESET, EOFError, RuntimeError].each do |type|
    define_method("test_shutdown_#{type.name.split('::').last}_preserves_the_original_error") do
      browser = activate_browser
      error = Net::ReadTimeout.new('original reset error')
      @driver.stubs(:reset!).raises(error)
      browser.expects(:quit).once.raises(type.new('shutdown failed'))

      assert_discarded(error, 'Browser shutdown failed')
    end
  end

  def test_assertion_screenshot_and_reset_failures_remain_in_order
    browser = activate_browser
    disconnect = Selenium::WebDriver::Error::InvalidArgumentError.new("'handle' must be a string")
    @driver.stubs(:reset!).raises(disconnect)
    browser.stubs(:quit).raises(Errno::ECONNRESET)
    body_calls = 0
    body = lambda do
      body_calls += 1
      raise Minitest::Assertion, 'original assertion'
    end
    screenshot = -> { raise Selenium::WebDriver::Error::NoSuchWindowError, 'screenshot window closed' }

    result, = run_example(body: body, screenshot: screenshot)

    assert_equal 1, body_calls
    assert_equal 3, result.failures.size
    assert_equal 'original assertion', result.failures.first.message
    assert_includes result.failures[1].message, 'screenshot window closed'
    assert_same disconnect, result.failures[2].error
  end

  def test_session_cleanup_error_cannot_replace_the_teardown_failure
    activate_browser
    error = Net::ReadTimeout.new('original reset error')
    @driver.stubs(:reset!).raises(error)
    @session.expects(:quit).twice.raises(RuntimeError, 'framework cleanup failed')

    result, output = run_example

    assert_equal 1, result.failures.size
    assert_same error, result.failures.first.error
    assert_includes output, 'Session cleanup failed'
  end
end
