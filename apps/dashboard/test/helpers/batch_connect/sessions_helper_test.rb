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

  def create_session(state = :running)
    value = '{"id":"1234","job_id":"1","created_at":1669139262,"token":"sys/token","title":"AppName","cache_completed":false}'
    BatchConnect::Session.new.from_json(value).tap do |session|
      session.stubs(:status).returns(OodCore::Job::Status.new(state: state))
    end
  end

  def cancel_session_title
    "#{I18n.t('dashboard.batch_connect_sessions_cancel_title')} AppName #{I18n.t('dashboard.batch_connect_sessions_word')}"
  end

  def delete_session_title
    "#{I18n.t('dashboard.batch_connect_sessions_delete_title')} AppName #{I18n.t('dashboard.batch_connect_sessions_word')}"
  end
end