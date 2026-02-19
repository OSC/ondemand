# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  DOWNLOAD_DIRECTORY = Rails.root.join('tmp', 'downloads')

  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |options|
    # only chrome has support for browser logs
    options.logging_prefs = { browser: 'ALL' }
    options.add_argument('--headless=new')
    options.browser_version = 'stable'

    profile = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_DIRECTORY

    options.profile = profile
  end

  Selenium::WebDriver.logger.level = :debug unless ENV['DEBUG'].nil?
  Capybara.server = :webrick

  def find_option_style(ele, opt)
    find("##{bc_ele_id(ele)} option[value='#{opt}']")['style'].to_s
  end

  def find_all_options(ele, opt)
    if opt.nil?
      all("##{bc_ele_id(ele)} option")
    else
      all("##{bc_ele_id(ele)} option[value='#{opt}']")
    end
  end

  def find_max(ele)
    find("##{bc_ele_id(ele)}")['max'].to_i
  end

  def find_min(ele)
    find("##{bc_ele_id(ele)}")['min'].to_i
  end

  def find_value(ele, visible: false)
    find("##{bc_ele_id(ele)}", visible: visible).value
  end

  def checked?(ele)
    find("##{bc_ele_id(ele)}").checked?
  end

  def find_css_class(id)
    find("##{id}")['class'].to_s
  end

  def verify_bc_alert(token, header, message)
    assert_equal batch_connect_session_contexts_path(token), current_path
    assert_equal header, find('div[role="alert"]').find('h4').text
    assert_equal message, find('div[role="alert"]').find('pre').text
    find('div[role="alert"]').find('button').click
  end
end
