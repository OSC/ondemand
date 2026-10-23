# frozen_string_literal: true

require 'test_helper'
require 'html_helper'

class AppverseNavigationTest < ActionDispatch::IntegrationTest
  def setup
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys'))
  end

  test 'help menu omits Appverse link when OOD_DASHBOARD_APPVERSE_URL is unset' do
    get root_path
    assert_response :success

    menu_links = css_select(dropdown_list('Help'), 'a')
    appverse_link = menu_links.find { |link| link.text.include?('Appverse') }

    assert_nil appverse_link
  end

  test 'help menu includes Appverse link when OOD_DASHBOARD_APPVERSE_URL is set' do
    with_modified_env(OOD_DASHBOARD_APPVERSE_URL: 'https://ondemand.connectci.org/appverse') do
      get root_path
      assert_response :success

      menu_links = css_select(dropdown_list('Help'), 'a')
      appverse_link = menu_links.find { |link| link.text.include?('Appverse') }

      assert appverse_link, 'Appverse link not found in Help menu'
      assert_equal 'https://ondemand.connectci.org/appverse', appverse_link['href']
      assert_equal '_blank', appverse_link['target']
    end
  end
end
