# frozen_string_literal: true

require 'minitest/autorun'
require 'mocha/minitest'
require_relative '../support/quit_failed_selenium_driver'

class QuitFailedSeleniumDriverTest < Minitest::Test
  def setup
    @driver = Capybara::Selenium::Driver.new(nil, browser: :chrome)
    bridge = stub('bridge', log: nil, commands: true)
    @browser = mock('browser', browser: :chrome, bridge: bridge)
    @driver.instance_variable_set(:@browser, @browser)
    @driver.send(:specialize_driver)
  end

  def test_keeps_the_reset_error_when_quitting_also_fails
    original = Selenium::WebDriver::Error::InvalidSessionIdError.new('browser crashed')
    @driver.expects(:window_handles).raises(original)
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
    @driver.stubs(:window_handles).returns(['tab'])
    @driver.stubs(:switch_to_window).with('tab')
    @driver.stubs(:chromedriver_version).returns(151)
    @browser.stubs(:navigate).returns(stub('navigation', to: nil))
    @driver.stubs(:wait_for_empty_page)
    @driver.expects(:execute_cdp)
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
