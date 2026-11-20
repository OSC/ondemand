# frozen_string_literal: true

require 'minitest/autorun'
require 'mocha/minitest'
require_relative '../support/quit_failed_selenium_driver'

class QuitFailedSeleniumDriverTest < Minitest::Test
  def setup
    @driver = Capybara::Selenium::Driver.new(nil, browser: :chrome)
    @browser = mock('browser')
    @driver.instance_variable_set(:@browser, @browser)
  end

  def test_keeps_the_reset_error_when_quitting_also_fails
    original = Selenium::WebDriver::Error::InvalidSessionIdError.new('browser crashed')
    @driver.expects(:reset_browser_state).raises(original)
    @browser.expects(:quit).raises(IOError, 'quit failed')

    _stdout, stderr = capture_io do
      error = assert_raises(Selenium::WebDriver::Error::InvalidSessionIdError) { @driver.reset! }
      assert_same original, error
    end
    assert_includes stderr, 'quit failed'
    assert_nil @driver.instance_variable_get(:@browser)
  end

  def test_keeps_the_browser_when_a_server_error_surfaces_after_reset
    original = RuntimeError.new('Rails request failed')
    @driver.expects(:reset_browser_state)
    @driver.stubs(:wait_for_empty_page)
    @browser.expects(:quit).never
    server = stub('server', wait_for_pending_requests: nil, error: original, reset_error!: nil)
    session = Capybara::Session.new(:selenium)
    session.stubs(:driver).returns(@driver)
    session.stubs(:switch_to_frame)
    session.instance_variable_set(:@server, server)
    session.instance_variable_set(:@touched, true)

    error = assert_raises(RuntimeError) { session.reset! }
    assert_same original, error
    assert_same @browser, @driver.instance_variable_get(:@browser)
  end
end
