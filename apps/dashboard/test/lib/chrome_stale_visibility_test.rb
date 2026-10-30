# frozen_string_literal: true

require 'minitest/autorun'
require 'mocha/minitest'
require_relative '../support/chrome_stale_visibility'

# Exercise real Chrome nodes and Capybara synchronization without a browser.
class ChromeStaleVisibilityTest < Minitest::Test
  STALE_NODE_MESSAGE = 'unknown error: unhandled inspector error: ' \
                       '{"code":-32000,"message":"Node with given id does not belong to the document"}'

  # Disable the native visibility endpoint so the test follows the logged stack.
  def setup
    @driver = Capybara::Selenium::Driver.new(nil, browser: :chrome, native_displayed: false)
    @session = Capybara::Session.new(:selenium)
    @session.stubs(:driver).returns(@driver)
  end

  # Create a real driver node with only its remote element transport mocked.
  def chrome_node(native)
    Capybara::Selenium::ChromeNode.new(@driver, native)
  end

  def test_preserves_visible_and_hidden_results
    native = mock('element')
    native.expects(:displayed?).twice.returns(true, false)
    node = chrome_node(native)

    assert_equal true, node.visible?
    assert_equal false, node.visible?
  end

  def test_normalizes_the_exact_unknown_error_and_preserves_its_cause
    original = Selenium::WebDriver::Error::UnknownError.new(STALE_NODE_MESSAGE)
    native = mock('detached element')
    native.expects(:displayed?).raises(original)

    error = assert_raises(Selenium::WebDriver::Error::StaleElementReferenceError) do
      chrome_node(native).visible?
    end

    assert_includes error.message, original.message
    assert_same original, error.cause
  end

  def test_propagates_unrelated_unknown_errors_without_retrying
    original = Selenium::WebDriver::Error::UnknownError.new('browser disconnected')
    native = mock('element')
    native.expects(:displayed?).once.raises(original)
    @driver.expects(:find_css).once.returns([chrome_node(native)])

    error = assert_raises(Selenium::WebDriver::Error::UnknownError) do
      @session.assert_selector('.alert-success')
    end

    assert_same original, error
  end

  def test_propagates_other_error_classes_even_with_the_same_message
    original = Selenium::WebDriver::Error::JavascriptError.new(STALE_NODE_MESSAGE)
    native = mock('element')
    native.expects(:displayed?).raises(original)

    error = assert_raises(Selenium::WebDriver::Error::JavascriptError) do
      chrome_node(native).visible?
    end

    assert_same original, error
  end

  def test_requeries_the_selector_after_the_visibility_error
    detached = mock('detached element')
    detached.expects(:displayed?).once.raises(Selenium::WebDriver::Error::UnknownError.new(STALE_NODE_MESSAGE))
    detached.stubs(:text).returns('')
    replacement = mock('replacement element')
    replacement.expects(:displayed?).once.returns(true)
    @driver.expects(:find_css).twice.returns([chrome_node(detached)], [chrome_node(replacement)])

    @session.assert_selector('.alert-success')
  end

  def test_stops_retrying_when_capybaras_deadline_expires
    timer = mock('retry deadline')
    Capybara::Helpers.expects(:timer).with(expire_in: 0.05).returns(timer)
    timer.expects(:expired?).twice.returns(false, true)
    native = mock('persistently detached element')
    native.expects(:displayed?).twice.raises(Selenium::WebDriver::Error::UnknownError.new(STALE_NODE_MESSAGE))
    native.stubs(:text).returns('')
    @driver.expects(:find_css).twice.returns([chrome_node(native)])

    @session.using_wait_time(0.05) do
      assert_raises(Capybara::ExpectationNotMet) do
        @session.assert_selector('.alert-success')
      end
    end
  end

  def test_leaves_click_errors_unchanged_without_resubmitting
    original = Selenium::WebDriver::Error::UnknownError.new(STALE_NODE_MESSAGE)
    native = mock('launch button')
    native.expects(:click).once.raises(original)

    error = assert_raises(Selenium::WebDriver::Error::UnknownError) do
      chrome_node(native).click
    end

    assert_same original, error
  end
end
