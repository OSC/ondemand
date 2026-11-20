# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'
require 'capybara/selenium/driver'

# Recover the driver whose reset failed. Capybara checks Rails server errors
# separately after resetting the driver.
module QuitFailedSeleniumDriver
  def reset!
    super
  rescue StandardError
    begin
      quit
    rescue StandardError => e
      warn "Selenium quit after a failed reset also failed: #{e.message}"
    end
    raise
  end
end

Capybara::Selenium::Driver.prepend(QuitFailedSeleniumDriver)
