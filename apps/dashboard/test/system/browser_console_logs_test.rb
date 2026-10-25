# frozen_string_literal: true

require 'application_system_test_case'
require_relative 'files_test'
require_relative 'remote_files_test'

# Exercise the actual Files hooks so restoring a per-example quit fails here.
class BrowserConsoleLogsTest < ApplicationSystemTestCase
  # Run the real setup and inherited Rails cleanup without retrying a failed body.
  class Example < ApplicationSystemTestCase
    attr_reader :body_calls

    def initialize(test_class)
      super('exercise')
      @test_class = test_class
      @body_calls = 0
    end

    def setup
      @test_class.new('unused').setup
    end

    def exercise
      @body_calls += 1
    end

    def take_failed_screenshot; end
  end

  [FilesTest, RemoteFilesTest].each do |test_class|
    define_method("test_#{test_class.name}_setup_drains_logs_without_replacing_chrome") do
      visit files_url(Rails.root.to_s)
      browser = page.driver.browser
      window = browser.window_handle
      marker = "browser-console-drain-#{test_class.name}"
      page.execute_script("console.error('#{marker}')")
      assert(browser.logs.get(:browser).any? { |entry| entry.message.include?(marker) })
      page.execute_script("console.error('#{marker}')")

      test_class.new('unused').setup

      assert_same browser, page.driver.browser
      assert_equal window, browser.window_handle
      assert_empty(browser.logs.get(:browser).select { |entry| entry.message.include?(marker) })
    end

    define_method("test_#{test_class.name}_console_failure_before_visit_releases_the_browser") do
      session = Capybara.current_session
      session.reset!
      driver = session.driver
      browser = driver.browser
      error = EOFError.new('console transport closed')
      logs = mock('failed console read')
      browser.stubs(:logs).returns(logs)
      logs.expects(:get).with(:browser).once.raises(error)

      example = Example.new(test_class)
      result = nil
      capture_io { result = example.run }

      assert_equal 0, example.body_calls
      assert_equal 1, result.failures.size
      assert_same error, result.failures.first.error
      refute_same driver, session.driver
      visit files_url(Rails.root.to_s)
      assert_selector '#directory-contents tbody a', exact_text: 'app'
      refute_same browser, page.driver.browser
    ensure
      session&.quit
    end
  end
end
