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

  test 'radio buttons and labels appear correctly' do
    get new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_select 'form input[id="batch_connect_session_context_mode_0"]'
    assert_select 'form input[id="batch_connect_session_context_mode_1"]'
    assert_equal 'The Mode', css_select('label[for="batch_connect_session_context_mode"]').text
    assert_equal 'Jupyter Lab', css_select('label[for="batch_connect_session_context_mode_1"]').text
    assert_equal 'Jupyter Notebook', css_select('label[for="batch_connect_session_context_mode_0"]').text
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
      assert_equal 'Jupyter Notebook', links[0]['title']
      assert_equal '/batch_connect/sys/bc_jupyter/session_contexts/new', links[0]['href']

      assert_equal 'Paraview', links[1]['title']
      assert_equal '/batch_connect/sys/bc_paraview/session_contexts/new', links[1]['href']
    end
  end

  test 'shared apps left menu should render when nav_bar property defined' do
    stub_usr_router
    BatchConnect::SessionContextsController.any_instance.stubs(:t).with('dashboard.batch_connect_apps_menu_title').returns('Interactive apps title')
    BatchConnect::SessionContextsController.any_instance.stubs(:t).with('dashboard.shared_apps_title').returns('Shared apps title')
    stub_user_configuration(
      {
        nav_bar: [
          { title: 'Test Apps',
            links: [
              { apps: 'sys/bc_paraview' }
            ] }
        ]
      }
    )

    get new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_response :success

    assert_select 'div.col-md-3 div.card div.card-header' do |menu_headers|
      assert_equal 2, menu_headers.size
      assert_equal 'Shared apps title', menu_headers[0].text
      assert_equal 'Interactive apps title', menu_headers[1].text
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
      assert_equal 'Jupyter Notebook', links[0]['title']
      assert_equal '/batch_connect/sys/bc_jupyter/session_contexts/new', links[0]['href']

      assert_equal 'Paraview', links[1]['title']
      assert_equal '/batch_connect/sys/bc_paraview/session_contexts/new', links[1]['href']
    end
  end

  test 'renders saved settings form fields when OOD_BC_SAVED_SETTINGS is true' do
    with_modified_env({ ENABLE_NATIVE_VNC: 'true', OOD_BC_SAVED_SETTINGS: 'true' }) do
      file = "#{Rails.root}/test/fixtures/file_output/user_settings/saved_settings_edit.yml"
      Configuration.stubs(:user_settings_file).returns(file)

      get new_batch_connect_session_context_url(token: 'sys/bc_paraview')
      assert_response :ok

      assert_select 'select#batch_connect_session_prefill_template'
      saved_template_options = css_select('select#batch_connect_session_prefill_template option')
      assert_equal 2, saved_template_options.size
      assert_equal '-- select saved settings --', saved_template_options[0].text.strip
      assert_equal 'edit_name', saved_template_options[1].text.strip
      assert_select 'input#batch_connect_session_template_name'
      assert_select 'input#batch_connect_session_save_template_submit'
    end
  end

  test 'edit saved settings renders BatchConnect Context page with settings values' do
    with_modified_env({ ENABLE_NATIVE_VNC: 'true', OOD_BC_SAVED_SETTINGS: 'true' }) do
      file = "#{Rails.root}/test/fixtures/file_output/user_settings/saved_settings_edit.yml"
      Configuration.stubs(:user_settings_file).returns(file)

      get batch_connect_edit_settings_path(token: 'sys/bc_paraview', id: 'edit_name')
      assert_response :ok

      assert_equal 'edit_account', css_select('input[name="batch_connect_session_context[bc_account]"]').first['value']
      assert_equal '10', css_select('input[name="batch_connect_session_context[bc_num_hours]"]').first['value']
      assert_equal '800x600',
                   css_select('input[name="batch_connect_session_context[bc_vnc_resolution]"]').first['value']
      assert_equal 'edit_name', css_select('input[name="template_name"]').first['value']
    end
  end

  test 'form header is rendered correctly' do
    get new_batch_connect_session_context_url('sys/bc_jupyter')
    header_link = css_select('span.form_header_supports_some_html>a').first
    assert_equal 'a link', header_link.text
    assert_equal 'https://openondemand.org', header_link['href']
  end
end
