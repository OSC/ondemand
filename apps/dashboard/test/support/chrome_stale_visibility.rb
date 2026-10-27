# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'
require 'capybara/selenium/driver'

# Normalize Chrome's misclassified stale-node error during visibility checks.
# Keep this in test support until the installed Capybara handles it upstream:
# https://github.com/teamcapybara/capybara/issues/2800
module ChromeStaleVisibility
  # Let Capybara reload a detached element within its existing retry deadline.
  def visible?
    super
  rescue Selenium::WebDriver::Error::UnknownError => e
    raise unless e.message.include?('Node with given id does not belong to the document')

    raise Selenium::WebDriver::Error::StaleElementReferenceError, e.message
  end
end

Capybara::Selenium::ChromeNode.prepend(ChromeStaleVisibility)
