# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'

# Preserve teardown failures while releasing unusable Selenium sessions.
module BrowserSessionCleanup
  DISCONNECTED_CHROME = /\A(?:unknown[ ]error:[ ])?(?:disconnected:|chrome[ ]not[ ]reachable\b|tab[ ]crashed\b|
    session[ ]deleted[ ]because[ ]of[ ]page[ ]crash\b)/x.freeze

  # A failed reset cannot establish isolation, regardless of its exception type.
  def after_teardown
    reset_completed = false
    super
    reset_completed = true
  ensure
    recover_browser(reset_completed)
  end

  private

  def recover_browser(reset_completed)
    return discard_browser('session teardown did not complete') unless reset_completed

    recorded_errors = failures.filter_map { |failure| failure.error if failure.respond_to?(:error) }
    error = recorded_errors.find { |candidate| dead_browser_error?(candidate) }
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
      session.driver.quit
    rescue StandardError => e
      warn("Browser shutdown failed: #{e.class}: #{e.message.lines.first.to_s.strip}")
    ensure
      # Native quit can raise before Session#quit clears its state. Selenium's
      # ensure clears its browser, so this second quit completes session cleanup.
      session.quit
    end
  rescue StandardError => e
    warn("Session cleanup failed: #{e.class}: #{e.message.lines.first.to_s.strip}")
  end
end
