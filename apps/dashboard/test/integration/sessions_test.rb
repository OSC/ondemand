# frozen_string_literal: true

require 'html_helper'
require 'test_helper'

class SessionsTest < ActionDispatch::IntegrationTest
  def setup
    stub_sys_apps
  end

  test 'default application menu renders correctly when nav_bar property defined' do
    BatchConnect::SessionsController.any_instance.expects(:t).with('dashboard.batch_connect_apps_menu_title').returns('Translations title')
    stub_user_configuration({nav_bar: [
      {title: 'Custom Apps',
       links: [
         {group: 'Custom Apps Dropdown Header'},
         {apps: 'sys/bc_paraview'},
         {apps: 'sys/bc_jupyter'},
       ]}
    ]})

    get batch_connect_sessions_url
    assert_response :success

    assert_select 'div.card div.card-header', text: 'Translations title'
    assert_select 'div.card p.header', text: 'Custom Apps Dropdown Header'
    assert_select 'div.card div.list-group a.list-group-item', 2
    assert_select 'div.card div.list-group a.list-group-item' do |links|
      # Items are sorted by title
      assert_equal 'Jupyter Notebook', links[0]['data-title']
      assert_equal '/batch_connect/sys/bc_jupyter/session_contexts/new', links[0]['href']

      assert_equal 'Paraview', links[1]['data-title']
      assert_equal '/batch_connect/sys/bc_paraview/session_contexts/new', links[1]['href']
    end
  end

  test 'interactive_apps_menu override renders correctly' do
    stub_user_configuration({
    interactive_apps_menu: {
      title: 'Menu Title',
      links: [
        {group: 'Submenu Title'},
        {apps: 'sys/bc_jupyter'},
        {apps: 'sys/bc_paraview'}
      ]}
    })

    get batch_connect_sessions_url
    assert_response :success

    assert_select 'div.card div.card-header', text: 'Menu Title'
    assert_select 'div.card p.header', text: 'Submenu Title'
    assert_select 'div.card div.list-group a.list-group-item', 2
    assert_select 'div.card div.list-group a.list-group-item' do |links|
      # Configuration order must be kept
      assert_equal 'Jupyter Notebook', links[0]['data-title']
      assert_equal '/batch_connect/sys/bc_jupyter/session_contexts/new', links[0]['href']

      assert_equal 'Paraview', links[1]['data-title']
      assert_equal '/batch_connect/sys/bc_paraview/session_contexts/new', links[1]['href']
    end
  end
end
