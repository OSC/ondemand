# frozen_string_literal: true

require 'html_helper'
require 'test_helper'

# Test the new radio button functionality in the Jupyter Job Form
# Testing that radio button with value 0 exists
# Testing that radio button with value 1 exists
# Testing that radio button label exists

class BatchConnectTest < ActionDispatch::IntegrationTest
  def setup
    stub_sys_apps
  end

  test 'radio buttons and labels appear correctly with 3.0 compatability' do
    with_modified_env({'OOD_BC_RADIO_3_0_COMPATIBLE': 'true'}) do
      get new_batch_connect_session_context_url('sys/bc_jupyter')
      assert_select 'form input[id="batch_connect_session_context_mode_0"]'
      assert_select 'form input[id="batch_connect_session_context_mode_1"]'
      assert_equal 'The Mode', css_select('label[for="batch_connect_session_context_mode"]').text
      assert_equal 'Jupyter Lab', css_select('label[for="batch_connect_session_context_mode_1"]').text
      assert_equal 'Jupyter Notebook', css_select('label[for="batch_connect_session_context_mode_0"]').text
    end
  end

  # same as test above but for 2.0- form definitions
  test 'radio buttons and labels appear correctly with 2.0 compatability' do
    with_modified_env({'OOD_BC_RADIO_3_0_COMPATIBLE': 'false'}) do
      file = 'test/fixtures/sys_with_gateway_apps/bc_jupyter/form.yml'

      `sed -i 's#"1","Jupyter Lab"#"Jupyter Lab", "1"#g' #{file}`
      `sed -i 's#"0","Jupyter Notebook"#"Jupyter Notebook", "0"#g' #{file}`

      get new_batch_connect_session_context_url('sys/bc_jupyter')
      assert_select 'form input[id="batch_connect_session_context_mode_0"]'
      assert_select 'form input[id="batch_connect_session_context_mode_1"]'
      assert_equal 'The Mode', css_select('label[for="batch_connect_session_context_mode"]').text
      assert_equal 'Jupyter Lab', css_select('label[for="batch_connect_session_context_mode_1"]').text
      assert_equal 'Jupyter Notebook', css_select('label[for="batch_connect_session_context_mode_0"]').text

      `git checkout #{file}`
    end
  end

  test 'default application menu renders correctly when nav_bar property defined' do
    BatchConnect::SessionContextsController.any_instance.expects(:t).with('dashboard.batch_connect_apps_menu_title').returns('Translations title')
    stub_user_configuration({nav_bar: [
      {title: 'Custom Apps',
       links: [
         {group: 'Custom Apps Dropdown Header'},
         {apps: 'sys/bc_paraview'},
         {apps: 'sys/bc_jupyter'},
       ]}
    ]})

    get new_batch_connect_session_context_url('sys/bc_jupyter')
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

    get new_batch_connect_session_context_url('sys/bc_jupyter')
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
