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
      assert_equal 'Jupyter Notebook', links[0]['data-title']
      assert_equal '/batch_connect/sys/bc_jupyter/session_contexts/new', links[0]['href']

      assert_equal 'Paraview', links[1]['data-title']
      assert_equal '/batch_connect/sys/bc_paraview/session_contexts/new', links[1]['href']
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
      assert_equal 'Jupyter Notebook', links[0]['data-title']
      assert_equal '/batch_connect/sys/bc_jupyter/session_contexts/new', links[0]['href']

      assert_equal 'Paraview', links[1]['data-title']
      assert_equal '/batch_connect/sys/bc_paraview/session_contexts/new', links[1]['href']
    end
  end

  test 'should render session panel with delete button when cancel_session_enabled is false (default)' do
    Configuration.stubs(:cancel_session_enabled).returns(false)

    get batch_connect_sessions_path
    assert_response :success

    assert_select 'div#id_1234 div.card-body div.float-right form' do |form|
      assert_equal I18n.t('dashboard.batch_connect_sessions_delete_title'), form.first.text.strip
      assert_equal batch_connect_session_path('1234'), form.first['action']
    end
  end

  test 'should render session panel with cancel button when cancel_session_enabled is true' do
    Configuration.stubs(:cancel_session_enabled).returns(true)

    get batch_connect_sessions_path
    assert_response :success

    assert_select 'div#id_1234 div.card-body div.float-right form' do |form|
      assert_equal I18n.t('dashboard.batch_connect_sessions_cancel_title'), form.first.text.strip
      assert_equal batch_connect_cancel_session_path('1234'), form.first['action']
    end
  end

  test 'should render session panel with relaunch button' do
    value = '{"id":"1234","job_id":"1","created_at":1669139262,"token":"sys/token","title":"session title","cache_completed":true}'
    session = BatchConnect::Session.new.from_json(value)
    session.stubs(:status).returns(OodCore::Job::Status.new(state: :completed))
    session.stubs(:app).returns(stub(valid?: true, token: 'sys/token', attributes: [], session_info_view: nil, session_completed_view: nil, ssh_allow?: true))
    BatchConnect::Session.stubs(:all).returns([session])

    get batch_connect_sessions_path
    assert_response :success

    assert_select 'div#id_1234 div.card-heading div.float-right form.relaunch' do |form|
      assert_equal batch_connect_session_contexts_path(token: 'sys/token'), form.first['action']
    end
  end
end
