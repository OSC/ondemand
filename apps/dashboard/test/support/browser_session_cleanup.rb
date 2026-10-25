# frozen_string_literal: true

require 'English'
require 'capybara'
require 'selenium-webdriver'

# Preserve teardown failures while releasing unusable Selenium sessions.
module BrowserSessionCleanup
  DEAD_CONNECTION_ERRORS = [Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError].freeze
  DISCONNECTED_CHROME = /\A(?:unknown error: )?(?:disconnected:|chrome not reachable\b)/.freeze

  # Reading Chrome's console log drains it without restarting a healthy browser.
  def clear_browser_logs
    page.driver.browser.logs.get(:browser)
  end

  def after_teardown
    super
  ensure
    recover_dead_browser($ERROR_INFO)
  end

  private

  def recover_dead_browser(teardown_error)
    recorded_errors = failures.filter_map { |failure| failure.error if failure.respond_to?(:error) }
    error = [teardown_error, *recorded_errors].compact.find { |candidate| dead_browser_error?(candidate) }
    discard_dead_browser(error) if error
  rescue StandardError => e
    warn("Session cleanup failed: #{e.class}: #{e.message.lines.first.to_s.strip}")
  end

  def dead_browser_error?(error)
    error.is_a?(Selenium::WebDriver::Error::InvalidSessionIdError) ||
      DEAD_CONNECTION_ERRORS.any? { |type| error.is_a?(type) } ||
      (error.is_a?(Selenium::WebDriver::Error::UnknownError) && DISCONNECTED_CHROME.match?(error.message))
  end

  def discard_dead_browser(error)
    session = Capybara.current_session
    warn("#{self.class}##{name}: discarding dead browser (#{error.class}: #{error.message.lines.first.to_s.strip})")
    begin
      session.driver.quit
    rescue StandardError => e
      warn("Browser shutdown failed: #{e.class}: #{e.message.lines.first.to_s.strip}")
    ensure
      # Selenium clears its native browser in ensure, even if quit fails. Finish
      # Capybara's document, driver and touched-state cleanup after that release.
      session.quit
    end
  rescue StandardError => e
    warn("Session cleanup failed: #{e.class}: #{e.message.lines.first.to_s.strip}")
  end
end
