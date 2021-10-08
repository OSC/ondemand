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

  def find_option_style(ele, opt)
    find("##{bc_ele_id(ele)} option[value='#{opt}']")['style'].to_s
  end

  def find_max(ele)
    find("##{bc_ele_id(ele)}")['max'].to_i
  end

  def find_min(ele)
    find("##{bc_ele_id(ele)}")['min'].to_i
  end
end
