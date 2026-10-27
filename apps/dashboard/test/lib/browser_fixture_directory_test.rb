# frozen_string_literal: true

require 'test_helper'
require 'action_dispatch/system_testing/test_helpers/setup_and_teardown'
require 'action_dispatch/system_testing/test_helpers/screenshot_helper'
require_relative '../support/browser_fixture_directory'

# Exercise real Rails/Minitest teardown ordering without starting a browser.
class BrowserFixtureDirectoryTest < ActiveSupport::TestCase
  # Run an isolated example through Minitest's real exception-collection lifecycle.
  class Example < Minitest::Test
    include ActionDispatch::SystemTesting::TestHelpers::ScreenshotHelper
    include ActionDispatch::SystemTesting::TestHelpers::SetupAndTeardown
    include BrowserFixtureDirectory

    attr_reader :directory, :events
    attr_accessor :reset_error, :screenshot_error, :body_error

    def initialize
      super('exercise')
      @events = []
    end

    def page
      example = self
      Object.new.tap do |page|
        page.define_singleton_method(:reset!) do
          example.events << [:reset, File.directory?(example.directory)]
          raise example.reset_error if example.reset_error
        end
      end
    end

    def exercise
      with_browser_fixture_directory do |directory|
        @directory = directory
        raise body_error if body_error
      end
      events << [:after_block, File.directory?(directory)]
    end

    def take_failed_screenshot
      return unless failed?

      events << [:screenshot, File.directory?(directory)]
      raise screenshot_error if screenshot_error
    end

    # Isolate the helper's early reset; these examples omit Rails' later reset_sessions!.
    def after_teardown; end
  end

  test 'fixtures remain through the body and reset runs before removal' do
    example = Example.new
    result = example.run
    assert result.passed?
    assert_equal [[:after_block, true], [:reset, true]], example.events
    refute File.exist?(example.directory)
  end

  test 'failed screenshots precede browser reset while fixtures exist' do
    example = Example.new
    example.body_error = Minitest::Assertion.new('original assertion')
    result = example.run
    assert_equal ['original assertion'], result.failures.map(&:message)
    assert_equal [[:screenshot, true], [:reset, true]], example.events
    refute File.exist?(example.directory)
  end

  test 'reset errors do not replace the original assertion' do
    example = Example.new
    example.body_error = Minitest::Assertion.new('original assertion')
    example.reset_error = RuntimeError.new('reset failure')
    result = example.run
    assert_equal 2, result.failures.size
    assert_match(/original assertion/, result.failures.first.message)
    assert_match(/reset failure/, result.failures.last.message)
    refute File.exist?(example.directory)
  end

  test 'reset errors are reported even without an earlier failure' do
    example = Example.new
    example.reset_error = RuntimeError.new('reset failure')
    result = example.run
    assert_equal 1, result.failures.size
    assert_match(/reset failure/, result.failures.first.message)
    refute File.exist?(example.directory)
  end

  test 'screenshot errors still reset and remove fixtures without losing the assertion' do
    example = Example.new
    example.body_error = Minitest::Assertion.new('original assertion')
    example.screenshot_error = RuntimeError.new('screenshot failure')
    result = example.run
    assert_equal 2, result.failures.size
    assert_match(/original assertion/, result.failures.first.message)
    assert_match(/screenshot failure/, result.failures.last.message)
    assert_equal [[:screenshot, true], [:reset, true]], example.events
    refute File.exist?(example.directory)
  end
end
