# frozen_string_literal: true

require 'test_helper'

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
                profile: 'profile1' }
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
    assert_select '#navbar li.dropdown[title]', 2

    # Check custom "Help Menu"
    assert_select nav_menu(1) do |menu|
      assert_select menu.first, 'a', text: 'Help Menu'
      assert_select menu.first, 'ul' do |menu_items|
        menu_items.first['class'].include?('dropdown-menu-right')
      end
    end
    assert_select nav_menu_header('Help Menu'), text: 'Help Menu Dropdown Header'
    assert_select nav_menu_links('Help Menu') do |elements|
      assert_equal 2, elements.size
      assert_match(/Menu Link/, elements[0].text)
      assert_equal '/menu/link', elements[0]['href']
      assert_nil elements[0]['target']
      check_icon(elements[0], 'fa-cog')
    end

    # Check custom 'Docs Menu'
    assert_select nav_menu(2) do |menu|
      assert_select menu.first, 'a', text: 'Docs Menu'
      assert_select menu.first, 'ul' do |menu_items|
        menu_items.first['class'].include?('dropdown-menu-right')
      end
    end
    assert_select nav_menu_header('Docs Menu'), text: 'Docs Menu Dropdown Header'
    assert_select nav_menu_links('Docs Menu') do |elements|
      assert_equal 1, elements.size
      assert_match(/Jupyter Notebook/, elements[0].text)
      assert_equal '/batch_connect/sys/bc_jupyter/session_contexts/new', elements[0]['href']
      assert_nil elements[0]['target']
      check_icon(elements[0], 'fa-gear')
    end

    # Check custom link
    assert_select nav_link('Custom Help Link'), text: 'Custom Help Link'
    assert_select nav_link('Custom Help Link') do |link|
      assert_equal '/custom/link', link.first['href']
      assert_equal '_blank', link.first['target']
      check_icon(link.first, 'fa-desktop')
    end

    # User
    assert_select '#navbar .navbar-nav a.nav-link.disabled' do |link|
      assert_match(/Logged in as/, link.first.text.strip)
      check_icon(link.first, 'fa-user')
    end

    # Log out link
    assert_select "#navbar .navbar-nav a.nav-link[href='/logout']" do |link|
      assert_equal '/logout', link.first['href']
      assert_equal 'Log Out', link.first.text.strip
      check_icon(link.first, 'fa-sign-out-alt')
    end
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
    assert_select '#navbar li.dropdown[title]', 1
    assert_select nav_menu(1) do |menu|
      assert_select menu.first, 'a', text: 'Develop'
    end

    Configuration.stubs(:app_development_enabled?).returns(false)
    get root_path
    assert_response :success
    assert_select '#navbar li.dropdown[title]', 0
  end

  def nav_menu(order)
    "#navbar .navbar-nav li.dropdown:nth-of-type(#{order})"
  end

  def nav_menu_links(title)
    "#navbar .navbar-nav li.dropdown[title='#{title}'] ul.dropdown-menu a"
  end

  def nav_menu_header(title)
    "#navbar .navbar-nav li.dropdown[title='#{title}'] ul.dropdown-menu li.dropdown-header"
  end

  def nav_link(title)
    "#navbar .navbar-nav a.nav-link[title='#{title}']"
  end

  def check_icon(parent_element, icon_class)
    assert_select parent_element, 'i' do |icons|
      assert_equal true, icons.first['class'].include?(icon_class)
    end
  end
end
