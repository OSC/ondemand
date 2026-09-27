require 'test_helper'

class BatchConnect::SessionsHelperTest < ActionView::TestCase

  include ApplicationHelper
  include BatchConnect::SessionsHelper

  test 'cancel_or_delete should generate cancel button when cancel_session_enabled is true and state not completed' do
    Configuration.stubs(:cancel_session_enabled).returns(true)
    OodCore::Job::Status.states.each do |state|
      next if state == :completed

      html = Nokogiri::HTML(cancel_or_delete(create_session(state)))
      button = html.at_css('button')
      assert_equal true, button['class'].include?('btn-cancel')
      assert_equal I18n.t('dashboard.batch_connect_sessions_cancel_title'), button.text.strip
      assert_equal batch_connect_cancel_session_path('1234'), button.parent['action']
      assert_equal cancel_session_title, button['title']
    end
  end

  test 'cancel_or_delete should generate delete button when cancel_session_enabled is true and state completed' do
    Configuration.stubs(:cancel_session_enabled).returns(true)
    html = Nokogiri::HTML(cancel_or_delete(create_session(:completed)))
    button = html.at_css('button')
    assert_equal true, button['class'].include?('btn-delete')
    assert_equal I18n.t('dashboard.batch_connect_sessions_delete_title'), button.text.strip
    assert_equal batch_connect_session_path('1234'), button.parent['action']
    assert_equal delete_session_title, button['title']
  end

  test 'cancel_or_delete should generate delete button when cancel_session_enabled is false and state not completed' do
    Configuration.stubs(:cancel_session_enabled).returns(false)
    OodCore::Job::Status.states.each do |state|
      next if state == :completed

      html = Nokogiri::HTML(cancel_or_delete(create_session(state)))
      button = html.at_css('button')
      assert_equal true, button['class'].include?('btn-delete')
      assert_equal I18n.t('dashboard.batch_connect_sessions_delete_title'), button.text.strip
      assert_equal batch_connect_session_path('1234'), button.parent['action']
      assert_equal delete_session_title, button['title']
    end
  end

  test 'cancel_or_delete should generate delete button when cancel_session_enabled is false and state completed' do
    Configuration.stubs(:cancel_session_enabled).returns(false)
    html = Nokogiri::HTML(cancel_or_delete(create_session(:completed)))
    button = html.at_css('button')
    assert_equal true, button['class'].include?('btn-delete')
    assert_equal  I18n.t('dashboard.batch_connect_sessions_delete_title'), button.text.strip
    assert_equal batch_connect_session_path('1234'), button.parent['action']
    assert_equal delete_session_title, button['title']
  end

  test 'relaunch should add relaunch form when session is completed' do
    button = relaunch(create_session(:completed))

    html = Nokogiri::HTML(button)
    form = html.at_css('form')
    assert_equal batch_connect_session_contexts_path(token: 'sys/token'), form['action']
    assert_equal true, form['class'].include?('relaunch')

    button = html.at_css('button')
    assert_equal I18n.t('dashboard.batch_connect_sessions_relaunch_full_title', title: 'AppName'), button['title']
    assert_equal true, button['class'].include?('relaunch')
  end

  def create_session(state = :running, valid: true)
    value = '{"id":"1234","job_id":"1","created_at":1669139262,"token":"sys/token","title":"AppName","cache_completed":false}'
    BatchConnect::Session.new.from_json(value).tap do |session|
      session.stubs(:status).returns(OodCore::Job::Status.new(state: state))
      OpenStruct.new.tap do |sys_app|
        sys_app.send('valid?=', valid)
        sys_app.attributes = []
        sys_app.token = 'sys/token'
        session.stubs(:app).returns(sys_app)
      end
    end
  end

  def cancel_session_title
    I18n.t('dashboard.batch_connect_sessions_cancel_full_title', title: 'AppName')
  end

  def delete_session_title
    I18n.t('dashboard.batch_connect_sessions_delete_full_title', title: 'AppName')
  end

  test 'render_connection links a running Selkies session to its client with the session token' do
    session = create_session
    session.script_type = 'selkies'
    session.stubs(:starting?).returns(false)
    session.stubs(:view).returns(nil)
    session.stubs(:connect).returns(OpenStruct.new(host: 'node1', port: 8080, password: 'abc123'))

    link = Nokogiri::HTML(render_connection(session)).at_css('a.btn-primary')

    assert_equal '/rnode/node1/8080/?token=abc123', link['href']
    assert_equal 'Launch AppName', link.text.strip
    assert_equal '_blank', link['target']
  end

  test 'connection_tabs marks the first tab as the default tab' do
    tabs = [
      { title: 'Tab One', partial: 'starting', locals: {} },
      { title: 'Tab Two', partial: 'queued', locals: {} }
    ]

    html = Nokogiri::HTML(connection_tabs('session-id', tabs))

    assert_equal 1, html.css('.nav-tabs .nav-link[data-default-tab="true"]').size
    assert_equal 'Tab One', html.at_css('.nav-tabs .nav-link[data-default-tab="true"]').text.strip
    assert_nil html.at_css('.nav-tabs .nav-link[href="#c_session-id_1"][data-default-tab]')
  end
end