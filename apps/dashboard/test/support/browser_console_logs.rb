# frozen_string_literal: true

# Console reads bypass Capybara's touched tracking and need their own error cleanup.
module BrowserConsoleLogs
  def clear_browser_logs
    session = Capybara.current_session
    session.driver.browser.logs.get(:browser)
  rescue StandardError
    release_browser_after_console_error(session)
    raise
  end

  private

  def release_browser_after_console_error(session)
    session.driver.quit
  rescue StandardError => e
    warn("Browser shutdown after console error failed: #{e.class}: #{e.message}")
  ensure
    begin
      # Capybara's Selenium driver clears its native browser even when quit raises.
      session.quit
    rescue StandardError => e
      warn("Session cleanup after console error failed: #{e.class}: #{e.message}")
    end
  end
end
