require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase

  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |options|
    # only chrome has support for browser logs
    options.logging_prefs =  { browser: 'ALL' }
  end

  Capybara.server = :webrick

  def find_option_style(ele, opt)
    find("##{bc_ele_id(ele)} option[value='#{opt}']")['style'].to_s
  end

  def find_all_options(ele, opt)
    all("##{bc_ele_id(ele)} option[value='#{opt}']")
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
