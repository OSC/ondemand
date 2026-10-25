# frozen_string_literal: true

# Loaded explicitly by the temporary debug job, never by normal tests.
require 'fileutils'
require 'selenium-webdriver'
require_relative 'events'

directory = ENV.fetch('CI_DEBUG_DIR')
FileUtils.mkdir_p(File.join(directory, 'crashes'))
Selenium::WebDriver::Chrome::Service.driver_path = ENV.fetch('CI_DEBUG_CHROMEDRIVER')
require 'application_system_test_case'

service = Selenium::WebDriver::Chrome::Service.new(
  path: ENV.fetch('CI_DEBUG_CHROMEDRIVER'),
  log:  File.open(File.join(directory, 'chromedriver-stderr.log'), 'a'),
  args: ['--verbose', '--append-log', "--log-path=#{directory}/chromedriver-protocol.log"]
)
ApplicationSystemTestCase.driven_by :selenium, using: :headless_chrome,
                                             screen_size: [1400, 1400], options: { service: service } do |options|
  options.binary = ENV.fetch('CI_DEBUG_CHROME')
  options.browser_version = nil
  options.logging_prefs = { browser: 'ALL' }
  options.add_argument('--headless=new')
  options.add_argument('--enable-logging=stderr')
  options.add_argument("--crash-dumps-dir=#{directory}/crashes")
  profile = Selenium::WebDriver::Chrome::Profile.new
  profile['download.default_directory'] = ApplicationSystemTestCase::DOWNLOAD_DIRECTORY.to_s
  options.profile = profile
end
ApplicationSystemTestCase.prepend(CiDebugEvents)
warn("CI_DEBUG chrome=#{ENV.fetch('CI_DEBUG_CHROME')} driver=#{ENV.fetch('CI_DEBUG_CHROMEDRIVER')}")
