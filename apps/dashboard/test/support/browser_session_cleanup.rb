# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'

# Preserve teardown failures while releasing unusable Selenium sessions.
module BrowserSessionCleanup
  # ChromeDriver can report the disconnect on a subsequent "from ..." cause line.
  DISCONNECTED_CHROME = /^(?:from[ ])?(?:unknown[ ]error:[ ])?
    (?:disconnected:|chrome[ ]not[ ]reachable\b|tab[ ]crashed\b|
    session[ ]deleted[ ]because[ ]of[ ]page[ ]crash\b)/x.freeze

  # Any failure in the teardown chain leaves session isolation unconfirmed.
  def after_teardown
    teardown_completed = false
    super
    teardown_completed = true
  ensure
    recover_browser(teardown_completed)
  end

  private

  def recover_browser(teardown_completed)
    return discard_browser('session teardown did not complete') unless teardown_completed

    error = failures.find { |failure| failure.respond_to?(:error) && dead_browser_error?(failure.error) }&.error
    discard_browser("unusable browser context: #{error.class}: #{error.message.lines.first.to_s.strip}") if error
  rescue StandardError => e
    warn("Session cleanup failed: #{e.class}: #{e.message.lines.first.to_s.strip}")
  end

  def dead_browser_error?(error)
    error.is_a?(Selenium::WebDriver::Error::InvalidSessionIdError) ||
      error.is_a?(Selenium::WebDriver::Error::NoSuchWindowError) ||
      (error.is_a?(Selenium::WebDriver::Error::UnknownError) && DISCONNECTED_CHROME.match?(error.message))
  end

  # Only the current session is released; these tests do not use named sessions.
  def discard_browser(reason)
    session = Capybara.current_session
    warn("#{self.class}##{name}: discarding browser session (#{reason})")
    begin
      session.quit
    rescue StandardError => e
      warn("Browser shutdown failed: #{e.class}: #{e.message.lines.first.to_s.strip}")
      # Selenium clears its browser in ensure; retry to finish Session#quit.
      session.quit
    end
  rescue StandardError => e
    warn("Session cleanup failed: #{e.class}: #{e.message.lines.first.to_s.strip}")
  end
end
