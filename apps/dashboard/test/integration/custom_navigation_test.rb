# frozen_string_literal: true

require 'test_helper'

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
    assert_select '#navbar li.dropdown[title]', 3 # +1 here is 'Help'
    # Check nav links
    assert_select '#navbar > ul > a.nav-link[title]', 2

    assert_select nav_menu(1), text: 'Custom Menu'
    assert_select nav_menu_header('Custom Menu'), text: 'Custom Menu Dropdown Header'
    assert_select nav_menu_links('Custom Menu') do |elements|
      assert_equal 2, elements.size
      assert_match(/Menu Link/, elements[0].text)
      assert_equal '/menu/link', elements[0]['href']
      assert_nil elements[0]['target']
      check_icon(elements[0], 'fa-cog')

      assert_match(/Profile Link/, elements[1].text)
      assert_equal '/settings?settings%5Bprofile%5D=profile1', elements[1]['href']
      assert_nil elements[1]['target']
      check_icon(elements[1], 'fa-cog')
    end

    assert_select nav_menu(2), text: 'Custom Apps'
    assert_select nav_menu_header('Custom Apps'), text: 'Custom Apps Dropdown Header'
    assert_select nav_menu_links('Custom Apps') do |elements|
      assert_equal 1, elements.size
      assert_match(/Jupyter Notebook/, elements[0].text)
      assert_equal '/batch_connect/sys/bc_jupyter/session_contexts/new', elements[0]['href']
      assert_nil elements[0]['target']
      check_icon(elements[0], 'fa-gear')
    end

    assert_select nav_link('Paraview'), text: 'Paraview'
    assert_select nav_link('Paraview') do |link|
      assert_equal '/batch_connect/sys/bc_paraview/session_contexts/new', link.first['href']
      assert_nil link.first['target']
      check_icon(link.first, 'fa-gear')
    end

    assert_select nav_link('Custom Link'), text: 'Custom Link'
    assert_select nav_link('Custom Link') do |link|
      assert_equal '/custom/link', link.first['href']
      assert_equal '_blank', link.first['target']
      check_icon(link.first, 'fa-desktop')
    end

    # Check all_apps static link.
    assert_select "#navbar .navbar-nav li.nav-item[title='All Apps']", text: 'All Apps'
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

  def nav_menu(order)
    "#navbar .navbar-nav li.dropdown:nth-of-type(#{order}) a"
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
