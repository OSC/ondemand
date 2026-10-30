# frozen_string_literal: true

require 'minitest/autorun'
require 'mocha/minitest'
require 'net/http'
require 'capybara'
require 'capybara/selenium/driver'
require 'selenium-webdriver'
require_relative '../support/browser_console_logs'

# Faults occur at the native log API before Capybara marks the session touched.
class BrowserConsoleLogsCleanupTest < Minitest::Test
  include BrowserConsoleLogs

  def setup
    Capybara.register_driver(:console_cleanup_test) do |app|
      Capybara::Selenium::Driver.new(app, browser: :chrome)
    end
    @session = Capybara::Session.new(:console_cleanup_test)
    Capybara.stubs(:current_session).returns(@session)
    @logs = mock('browser logs')
    @browser = stub('native browser', logs: @logs, quit: nil)
    @driver = @session.driver
    @driver.instance_variable_set(:@browser, @browser)
  end

  def test_successful_console_read_keeps_the_browser
    @logs.expects(:get).with(:browser).once.returns(['old entry'])
    @browser.expects(:quit).never

    assert_silent { assert_equal ['old entry'], clear_browser_logs }
    assert_same @driver, @session.driver
    assert_same @browser, @session.driver.browser
  end

  [EOFError, Errno::ECONNREFUSED, Errno::ECONNRESET, Net::ReadTimeout,
   Selenium::WebDriver::Error::UnknownError].each do |type|
    define_method("test_untouched_console_#{type.name.split('::').last}_releases_the_session") do
      error = type.new('native console read failed')
      @logs.expects(:get).with(:browser).once.raises(error)
      @browser.expects(:quit).once
      @driver.expects(:reset!).never

      assert_same error, assert_raises(type) { clear_browser_logs }
      @session.reset! # The same cleanup Rails runs after a setup failure.
      refute_same @driver, @session.driver
      assert_nil @session.driver.instance_variable_get(:@browser)
    end
  end

  [EOFError, Errno::ECONNRESET, RuntimeError].each do |type|
    define_method("test_shutdown_#{type.name.split('::').last}_cannot_hide_the_console_error") do
      error = Net::ReadTimeout.new('original console read failure')
      @logs.expects(:get).with(:browser).once.raises(error)
      @browser.expects(:quit).once.raises(type.new('native shutdown failed'))

      _stdout, output = capture_io do
        assert_same error, assert_raises(Net::ReadTimeout) { clear_browser_logs }
      end

      refute_same @driver, @session.driver
      assert_nil @session.driver.instance_variable_get(:@browser)
      assert_includes output, 'Browser shutdown after console error failed'
    end
  end

  def test_session_cleanup_failure_cannot_hide_the_console_error
    error = EOFError.new('original console read failure')
    @logs.expects(:get).with(:browser).once.raises(error)
    @browser.expects(:quit).once
    @session.expects(:quit).once.raises(RuntimeError, 'session cleanup failed')

    _stdout, output = capture_io do
      assert_same error, assert_raises(EOFError) { clear_browser_logs }
    end

    assert_nil @driver.instance_variable_get(:@browser)
    assert_includes output, 'Session cleanup after console error failed'
  end
end
