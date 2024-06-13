# frozen_string_literal: true

require 'test_helper'
require 'html_helper'

class CustomHelpNavigationTest < ActionDispatch::IntegrationTest
  test 'should render a custom help navigation menu when help_bar is defined in UserConfiguration' do
    # Mock the sys installed applications
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys_with_interactive_apps'))
    # Test a navigation item of each type
    stub_user_configuration(
      {
        nav_bar:  [{ url: '/test' }],
        help_bar: [
          { title: 'Help Menu',
            links: [
              { group: 'Help Menu Dropdown Header' },
              { title:   'Menu Link',
                url:     '/menu/link',
                new_tab: false },
              { title:   'Profile Link',
                profile: 'profile1',
                icon:    'fa://user'}
            ] },
          { title: 'Docs Menu',
            links: [
              { group: 'Docs Menu Dropdown Header' },
              { apps: ['sys/bc_jupyter'] }
            ] },
          { title:   'Custom Help Link',
            url:     '/custom/link',
            icon:    'fa://desktop',
            new_tab: true },
          'user',
          'log_out'
        ]
      }
    )

    get root_path
    assert_response :success

    # Check nav menus
    assert_select dropdown_links, 2
    assert_select dropdown_link(1), text: 'Help Menu'
    assert_select dropdown_link(2), text: 'Docs Menu'

    # Check custom 'Help Menu'
    menu_items = dropdown_list('Help Menu')
    assert_equal true, menu_items.first['class'].include?('dropdown-menu-end')
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
    check_icon(menu_links[1], 'fa-user')

    # Check custom 'Docs Menu'
    menu_items = dropdown_list('Docs Menu')
    assert_equal true, menu_items.first['class'].include?('dropdown-menu-end')
    menu_links = css_select(menu_items, 'a')
    assert_equal 1, menu_links.size
    # Check first expected link
    assert_match(/Jupyter Notebook/, menu_links[0].text)
    assert_equal '/batch_connect/sys/bc_jupyter/session_contexts/new', menu_links[0]['href']
    assert_nil menu_links[0]['target']
    check_icon(menu_links[0], 'fa-gear')

    # Check custom link
    link = nav_link('Custom Help Link')[0]
    assert_match /Custom Help Link/, link.text
    assert_equal '/custom/link', link['href']
    assert_equal '_blank', link['target']
    check_icon(link, 'fa-desktop')
    # User
    user = nav_link("Logged in as #{CurrentUser.name}")[0]
    check_icon(user, 'fa-user')

    # Log out link
    logout = nav_link('Log Out')[0]
    assert_match /Log Out/, logout.text
    assert_equal '/logout', logout['href']
    check_icon(logout, 'fa-sign-out-alt')
  end

  test 'develop template should not render when Configuration.app_development_enabled? is false' do
    stub_user_configuration(
      {
        nav_bar:  [{ url: '/test' }],
        help_bar: ['develop']
      }
    )

    Configuration.stubs(:app_development_enabled?).returns(true)
    get root_path
    assert_response :success
    assert_select dropdown_links, 1
    assert_select dropdown_link(1), text: 'Develop'

    Configuration.stubs(:app_development_enabled?).returns(false)
    get root_path
    assert_response :success
    assert_select dropdown_links, 0
  end

  def check_icon(parent_element, icon_class)
    assert_select parent_element, 'i' do |icons|
      assert_equal true, icons.first['class'].include?(icon_class)
    end
  end
end
