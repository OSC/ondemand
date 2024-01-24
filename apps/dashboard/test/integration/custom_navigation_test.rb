# frozen_string_literal: true

require 'test_helper'
require 'html_helper'

class CustomNavigationTest < ActionDispatch::IntegrationTest
  def setup
    # Mock the sys installed applications
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys_with_interactive_apps'))
  end

  test 'should render a custom navigation menu when nav_bar is defined in UserConfiguration' do
    # Test a navigation item of each type
    stub_user_configuration(
      {
        nav_bar: [
          { title: 'Custom Menu',
            links: [
              { group: 'Custom Menu Dropdown Header' },
              { title:   'Menu Link',
                url:     '/menu/link',
                new_tab: false },
              { title:   'Profile Link',
                profile: 'profile1' }
            ] },
          { title: 'Custom Apps',
            links: [
              { group: 'Custom Apps Dropdown Header' },
              { apps: ['sys/bc_jupyter'] }
            ] },
          { title:    'Custom Link',
            url:      '/custom/link',
            icon: 'fa://desktop',
            new_tab:  true },
          'sys/bc_paraview',
          'all_apps'
        ]
      }
    )

    get root_path
    assert_response :success

    # Check nav menus
    assert_select dropdown_links, 3
    assert_select dropdown_link(1), text: 'Custom Menu'
    assert_select dropdown_link(2), text: 'Custom Apps'
    assert_select dropdown_link(3), text: 'Help'

    menu_items = dropdown_list('Custom Menu')
    menu_links = css_select(menu_items, 'a')
    assert_equal 2, menu_links.size
    # Check first expected link
    assert_match(/Menu Link/, menu_links[0].text)
    assert_equal '/menu/link', menu_links[0]['href']
    assert_nil menu_links[0]['target']
    check_icon(menu_links[0], 'fa-cog')
    # Check second expected link
    assert_match(/Profile Link/, menu_links[1].text)
    assert_equal settings_path("settings[profile]" => "profile1"), menu_links[1]['href']
    assert_nil menu_links[1]['target']
    check_icon(menu_links[1], 'fa-cog')

    menu_headers = css_select(menu_items, 'li.dropdown-header')
    assert_equal 1, menu_headers.size
    assert_match(/Custom Menu Dropdown Header/, menu_headers[0].text)

    menu_items = dropdown_list('Custom Apps')
    menu_links = css_select(menu_items, 'a')
    assert_equal 1, menu_links.size
    # Check first expected link
    assert_match(/Jupyter Notebook/, menu_links[0].text)
    assert_equal '/batch_connect/sys/bc_jupyter/session_contexts/new', menu_links[0]['href']
    assert_nil menu_links[0]['target']
    check_icon(menu_links[0], 'fa-gear')

    menu_headers = css_select(menu_items, 'li.dropdown-header')
    assert_equal 1, menu_headers.size
    assert_match(/Custom Apps Dropdown Header/, menu_headers[0].text)

    # Check custom links
    link = nav_link('Paraview')[0]
    assert_match /Paraview/, link.text
    assert_equal '/batch_connect/sys/bc_paraview/session_contexts/new', link['href']
    assert_nil link['target']
    check_icon(link, 'fa-gear')

    link = nav_link('Custom Link')[0]
    assert_match /Custom Link/, link.text
    assert_equal '/custom/link', link['href']
    assert_equal '_blank', link['target']
    check_icon(link, 'fa-desktop')

    # Check all_apps static link.
    assert_equal 1, nav_link('All Apps').length
  end

  test 'featured_apps template should not break navigation when no pinned_apps defined' do
    stub_user_configuration(
      {
        pinned_apps: nil,
        nav_bar: ['featured_apps']
      }
    )

    get root_path
    assert_response :success
  end

  def check_icon(parent_element, icon_class)
    assert_select parent_element, 'i' do |icons|
      assert_equal true, icons.first['class'].include?(icon_class)
    end
  end
end
