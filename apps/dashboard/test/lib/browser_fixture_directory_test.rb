# frozen_string_literal: true

require 'test_helper'
require 'capybara'
require 'minitest/mock'
require 'action_dispatch/system_testing/test_helpers/setup_and_teardown'
require 'action_dispatch/system_testing/test_helpers/screenshot_helper'
require_relative '../support/browser_fixture_directory'

# Exercise Rails/Minitest teardown ordering without starting a browser.
class BrowserFixtureDirectoryTest < ActiveSupport::TestCase
  # Run an isolated example through Minitest's exception-collection lifecycle.
  class Example < Minitest::Test
    include ActionDispatch::SystemTesting::TestHelpers::ScreenshotHelper
    include ActionDispatch::SystemTesting::TestHelpers::SetupAndTeardown
    include BrowserFixtureDirectory

    attr_reader :directory, :events

    def initialize(body_error, screenshot_error)
      super('exercise')
      @body_error = body_error
      @screenshot_error = screenshot_error
      @events = []
    end

    def exercise
      with_browser_fixture_directory do |directory|
        @directory = directory
        raise Minitest::Assertion, @body_error if @body_error
      end
      events << [:after_block, File.directory?(directory)]
    end

    def take_failed_screenshot
      return unless failed?

      events << [:screenshot, File.directory?(directory)]
      raise @screenshot_error if @screenshot_error
    end
  end

  {
    'success'         => [nil, nil, nil],
    'assertion'       => ['original assertion', nil, nil],
    'reset'           => [nil, 'reset failure', nil],
    'assertion/reset' => ['original assertion', 'reset failure', nil],
    'screenshot'      => ['original assertion', nil, 'screenshot failure']
  }.each do |scenario, (body_error, reset_error, screenshot_error)|
    test "fixtures survive screenshots and reset, then are removed: #{scenario}" do
      example = Example.new(body_error, screenshot_error)
      reset = lambda do
        example.events << [:reset, File.directory?(example.directory)]
        raise reset_error if reset_error
      end

      result = Capybara.stub(:reset_sessions!, reset) { example.run }

      expected_events = body_error ? [[:screenshot, true]] : [[:after_block, true]]
      assert_equal expected_events + [[:reset, true]], example.events
      expected_errors = [body_error, screenshot_error, reset_error].compact
      assert_equal expected_errors.size, result.failures.size
      expected_errors.zip(result.failures).each do |message, failure|
        assert_includes failure.message, message
      end
      refute File.exist?(example.directory)
    end
  end
end
