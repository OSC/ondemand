require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # options = Selenium::WebDriver::Chrome::Options.new
  # options.add_preference "download.default_directory", "/tmp/downloads"
  # driven_by :selenium, using: :chrome, screen_size: [1400, 1400], options: options
  # driven_by :selenium, using: :chrome, screen_size: [1400, 1400], options: {
  #   prefs: { "download.default_directory" => "/tmp/downloads" }
  # }
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  Capybara.server = :webrick
end
