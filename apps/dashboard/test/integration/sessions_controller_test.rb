# frozen_string_literal: true

require 'html_helper'
require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    stub_sys_apps
    value = '{"id":"1234","job_id":"1","created_at":1669139262,"token":"sys/token","title":"session title","cache_completed":false}'
    session = BatchConnect::Session.new.from_json(value)
    session.stubs(:status).returns(OodCore::Job::Status.new(state: :running))
    BatchConnect::Session.stubs(:all).returns([session])
  end

  test 'default application menu renders correctly when nav_bar property defined' do
    BatchConnect::SessionsController.any_instance.expects(:t).with('dashboard.batch_connect_apps_menu_title').returns('Translations title')
    stub_user_configuration(
      {
        nav_bar: [
          { title: 'Custom Apps',
            links: [
              { group: 'Custom Apps Dropdown Header' },
              { apps: 'sys/bc_paraview' },
              { apps: 'sys/bc_jupyter' }
            ] }
        ]
      }
    )

    get batch_connect_sessions_path
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
    BatchConnect::SessionsController.any_instance.stubs(:t).with('dashboard.batch_connect_apps_menu_title').returns('Interactive apps title')
    BatchConnect::SessionsController.any_instance.stubs(:t).with('dashboard.shared_apps_title').returns('Shared apps title')
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

    get batch_connect_sessions_path
    assert_response :success

    assert_select 'nav.col-md-3 div.card div.card-header' do |menu_headers|
      assert_equal 2, menu_headers.size
      assert_equal 'Shared apps title', menu_headers[0].text
      assert_equal 'Interactive apps title', menu_headers[1].text
    end
  end

  test 'interactive_apps_menu override renders correctly' do
    stub_user_configuration(
      {
        interactive_apps_menu: {
          title: 'Menu Title',
          links: [
            { group: 'Submenu Title' },
            { apps: 'sys/bc_jupyter' },
            { apps: 'sys/bc_paraview' }
          ]
        }
      }
    )

    get batch_connect_sessions_path
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

  test 'should render session panel with delete button when cancel_session_enabled is false (default)' do
    Configuration.stubs(:cancel_session_enabled).returns(false)

    get batch_connect_sessions_path
    assert_response :success

    assert_select 'div#id_1234 div.card-body div.float-end form' do |form|
      assert_equal I18n.t('dashboard.batch_connect_sessions_delete_title'), form.first.text.strip
      assert_equal batch_connect_session_path('1234'), form.first['action']
    end
  end

  test 'should render session panel with cancel button when cancel_session_enabled is true' do
    Configuration.stubs(:cancel_session_enabled).returns(true)

    get batch_connect_sessions_path
    assert_response :success

    assert_select 'div#id_1234 div.card-body div.float-end form' do |form|
      assert_equal I18n.t('dashboard.batch_connect_sessions_cancel_title'), form.first.text.strip
      assert_equal batch_connect_cancel_session_path('1234'), form.first['action']
    end
  end

  test 'should render session panel with edit and relaunch button for completed sessions' do
    value = '{"id":"1234","job_id":"1","created_at":1669139262,"token":"sys/token","title":"session title","cache_completed":true}'
    session = BatchConnect::Session.new.from_json(value)
    session.stubs(:status).returns(OodCore::Job::Status.new(state: :completed))
    session.stubs(:app).returns(stub(valid?: true, preset?: false, token: 'sys/token', attributes: [], session_info_view: nil, session_completed_view: nil, ssh_allow?: true))
    BatchConnect::Session.stubs(:all).returns([session])

    get batch_connect_sessions_path
    assert_response :success

    assert_select 'div#id_1234 div.card-heading div.float-end form' do |forms|
      assert_equal 2, forms.size
      assert_equal true, forms[0]['class'].include?('edit-session')
      assert_equal new_batch_connect_session_context_path(token: 'sys/token'), forms[0]['action']

      assert_equal true, forms[1]['class'].include?('relaunch')
      assert_equal batch_connect_session_contexts_path(token: 'sys/token'), forms[1]['action']
    end
  end

  test 'should not render edit button for preset applications sessions' do
    value = '{"id":"1234","job_id":"1","created_at":1669139262,"token":"sys/token","title":"session title","cache_completed":true}'
    session = BatchConnect::Session.new.from_json(value)
    session.stubs(:status).returns(OodCore::Job::Status.new(state: :completed))
    session.stubs(:app).returns(stub(valid?: true, preset?: true, token: 'sys/token', attributes: [], session_info_view: nil, session_completed_view: nil, ssh_allow?: true))
    BatchConnect::Session.stubs(:all).returns([session])

    get batch_connect_sessions_path
    assert_response :success

    assert_select 'div#id_1234 div.card-heading div.float-end form' do |forms|
      assert_equal 1, forms.size
      assert_equal true, forms.first['class'].include?('relaunch')
    end
  end
end
