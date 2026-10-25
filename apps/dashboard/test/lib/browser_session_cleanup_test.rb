# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/mock'
require 'mocha/minitest'
require 'capybara'
require 'capybara/selenium/driver'
require 'action_dispatch/system_testing/test_helpers/setup_and_teardown'
require_relative '../support/browser_session_cleanup'

# Inject browser faults through real Capybara sessions and Rails lifecycle hooks.
class BrowserSessionCleanupTest < Minitest::Test
  # Manually run examples so intentional failures do not fail the containing test.
  class Example < Minitest::Test
    include ActionDispatch::SystemTesting::TestHelpers::SetupAndTeardown
    include BrowserSessionCleanup

    def initialize(name, body: nil, setup: nil, screenshot: nil)
      super(name)
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

    def page
      Capybara.current_session
    end

    def take_failed_screenshot
      @screenshot&.call(self) unless passed?
    end
  end

  def setup
    @drivers = []
    Capybara.register_driver(:browser_cleanup_test) do |app|
      driver = Capybara::Selenium::Driver.new(app, browser: :chrome)
      @drivers << driver
      driver
    end
    @session = Capybara::Session.new(:browser_cleanup_test)
    Capybara.stubs(:current_session).returns(@session)
  end

  def activate_browser
    browser = stub('native browser', navigate: stub(to: nil), quit: nil, window_handles: ['window'])
    @session.driver.instance_variable_set(:@browser, browser)
    @session.visit('http://example.test')
    browser
  end

  def run_example(body: nil, setup: nil, screenshot: nil)
    example = Example.new('exercise', body: body, setup: setup, screenshot: screenshot)
    result = nil
    output = nil
    Capybara.stub(:reset_sessions!, -> { @session.reset! }) do
      _stdout, output = capture_io { result = example.run }
    end
    [result, output]
  end

  def test_healthy_teardown_keeps_the_browser
    browser = activate_browser
    driver = @session.driver
    driver.stubs(:reset!)
    browser.expects(:quit).never

    result, output = run_example

    assert result.passed?
    assert_same driver, @session.driver
    assert_empty output
  end

  def test_created_but_unstarted_session_does_not_start_chrome
    driver = @session.driver
    Selenium::WebDriver.expects(:for).never
    Capybara.expects(:current_session).never

    result, = run_example

    assert result.passed?
    assert_nil driver.instance_variable_get(:@browser)
    assert_equal 1, @drivers.size
  end

  [
    [Selenium::WebDriver::Error::InvalidSessionIdError, 'invalid session id'],
    [Selenium::WebDriver::Error::UnknownError, 'disconnected: not connected to DevTools'],
    [Selenium::WebDriver::Error::UnknownError, 'unknown error: chrome not reachable'],
    [Errno::ECONNREFUSED, 'driver gone'],
    [Errno::ECONNRESET, 'connection reset'],
    [EOFError, 'connection closed']
  ].each_with_index do |(type, message), index|
    define_method("test_releases_confirmed_dead_session_#{index}") do
      browser = activate_browser
      driver = @session.driver
      error = type.new(message)
      driver.stubs(:reset!).raises(error)
      browser.expects(:quit).once

      result, output = run_example

      assert_equal 1, result.failures.size
      assert_same error, result.failures.first.error
      refute_same driver, @session.driver
      assert_nil @session.driver.instance_variable_get(:@browser)
      assert_includes output, 'discarding dead browser'
    end
  end

  [Selenium::WebDriver::Error::InvalidArgumentError, Selenium::WebDriver::Error::UnknownError,
   Net::ReadTimeout, ArgumentError, Selenium::WebDriver::Error::SessionNotCreatedError].each do |type|
    define_method("test_preserves_unrelated_#{type.name.split('::').last}") do
      browser = activate_browser
      driver = @session.driver
      error = type.new('unrelated failure')
      driver.stubs(:reset!).raises(error)
      browser.expects(:quit).never

      result, output = run_example

      assert_same error, result.failures.first.error
      assert_same driver, @session.driver
      assert_empty output
    end
  end

  [Errno::ECONNRESET, EOFError, RuntimeError].each do |type|
    define_method("test_shutdown_#{type.name.split('::').last}_preserves_the_original_error") do
      browser = activate_browser
      driver = @session.driver
      error = Selenium::WebDriver::Error::InvalidSessionIdError.new('original disconnect')
      driver.stubs(:reset!).raises(error)
      browser.stubs(:quit).raises(type.new('shutdown failed'))

      result, output = run_example

      assert_same error, result.failures.first.error
      assert_equal 1, result.failures.size
      refute_same driver, @session.driver
      assert_includes output, 'Browser shutdown failed'
    end
  end

  def test_session_cleanup_error_cannot_replace_the_teardown_failure
    activate_browser
    error = Selenium::WebDriver::Error::InvalidSessionIdError.new('original disconnect')
    @session.driver.stubs(:reset!).raises(error)
    @session.stubs(:quit).raises(RuntimeError, 'framework cleanup failed')

    result, output = run_example

    assert_equal 1, result.failures.size
    assert_same error, result.failures.first.error
    assert_includes output, 'Session cleanup failed'
  end

  def test_setup_failure_before_navigation_is_released_even_when_reset_is_untouched
    browser = stub(quit: nil, window_handles: ['window'])
    driver = @session.driver
    driver.instance_variable_set(:@browser, browser)
    error = Selenium::WebDriver::Error::InvalidSessionIdError.new('log read lost session')

    result, = run_example(setup: -> { raise error })

    assert_same error, result.failures.first.error
    refute_same driver, @session.driver
  end

  def test_assertion_screenshot_and_reset_failures_remain_in_order
    browser = activate_browser
    disconnect = Selenium::WebDriver::Error::InvalidSessionIdError.new('reset disconnect')
    @session.driver.stubs(:reset!).raises(disconnect)
    browser.stubs(:quit).raises(Errno::ECONNRESET)
    body_calls = 0
    body = lambda do
      body_calls += 1
      raise Minitest::Assertion, 'original assertion'
    end
    screenshot = ->(_test) { raise Selenium::WebDriver::Error::InvalidSessionIdError, 'screenshot disconnect' }

    result, = run_example(body: body, screenshot: screenshot)

    assert_equal 1, body_calls
    assert_equal 3, result.failures.size
    assert_equal 'original assertion', result.failures.first.message
    assert_includes result.failures[1].message, 'screenshot disconnect'
    assert_same disconnect, result.failures[2].error
  end

  def test_console_drain_keeps_the_same_browser_and_propagates_read_errors
    browser = activate_browser
    logs = mock('console logs')
    browser.stubs(:logs).returns(logs)
    logs.expects(:get).with(:browser).twice.returns(['old entry']).then.raises(ArgumentError, 'read failed')
    example = Example.new('exercise')

    assert_equal ['old entry'], example.clear_browser_logs
    assert_same browser, @session.driver.browser
    assert_raises(ArgumentError) { example.clear_browser_logs }
  end
end
