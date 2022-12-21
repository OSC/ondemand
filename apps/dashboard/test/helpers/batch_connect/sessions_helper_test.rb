require 'test_helper'

class BatchConnect::SessionsHelperTest < ActionView::TestCase

  include ApplicationHelper
  include BatchConnect::SessionsHelper

  test 'cancel_or_delete should generate cancel button when cancel_session_enabled is true and state not completed' do
    Configuration.stubs(:cancel_session_enabled).returns(true)
    OodCore::Job::Status.states.each do |state|
      next if state == :completed

      html = Nokogiri::HTML(cancel_or_delete(create_session(state)))
      link = html.at_css('a')
      assert_equal true, link['class'].include?('btn-cancel')
      assert_equal I18n.t('dashboard.batch_connect_sessions_cancel_title'), link.text.strip
      assert_equal batch_connect_cancel_session_path('1234'), link['href']
    end
  end

  test 'cancel_or_delete should generate delete button when cancel_session_enabled is true and state completed' do
    Configuration.stubs(:cancel_session_enabled).returns(true)
    html = Nokogiri::HTML(cancel_or_delete(create_session(:completed)))
    link = html.at_css('a')
    assert_equal true, link['class'].include?('btn-delete')
    assert_equal I18n.t('dashboard.batch_connect_sessions_delete_title'), link.text.strip
    assert_equal batch_connect_session_path('1234'), link['href']
  end

  test 'cancel_or_delete should generate delete button when cancel_session_enabled is false and state not completed' do
    Configuration.stubs(:cancel_session_enabled).returns(false)
    OodCore::Job::Status.states.each do |state|
      next if state == :completed

      html = Nokogiri::HTML(cancel_or_delete(create_session(state)))
      link = html.at_css('a')
      assert_equal true, link['class'].include?('btn-delete')
      assert_equal I18n.t('dashboard.batch_connect_sessions_delete_title'), link.text.strip
      assert_equal batch_connect_session_path('1234'), link['href']
    end
  end

  test 'cancel_or_delete should generate delete button when cancel_session_enabled is false and state completed' do
    Configuration.stubs(:cancel_session_enabled).returns(false)
    html = Nokogiri::HTML(cancel_or_delete(create_session(:completed)))
    link = html.at_css('a')
    assert_equal true, link['class'].include?('btn-delete')
    assert_equal  I18n.t('dashboard.batch_connect_sessions_delete_title'), link.text.strip
    assert_equal batch_connect_session_path('1234'), link['href']
  end

  def create_session(state = :running)
    value = '{"id":"1234","job_id":"1","created_at":1669139262,"token":"sys/token","title":"session title","cache_completed":false}'
    BatchConnect::Session.new.from_json(value).tap do |session|
      session.stubs(:status).returns(OodCore::Job::Status.new(state: state))
    end
  end

end