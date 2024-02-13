require 'html_helper'
require 'test_helper'

class ActiveSessionsWidgetTest < ActionDispatch::IntegrationTest

  def setup
    stub_user_configuration({
      dashboard_layout: {
        rows: [{columns: [{width: 12, widgets: ['sessions']}]}]
      }
    })
  end

  test 'should not render active sessions widget when no active sessions' do
    BatchConnect::Session.stubs(:all).returns([])

    get '/'

    assert_select 'div.active-sessions-header h3', 0
  end

  test 'should render active sessions widget with session card' do
    value = '{"id":"1234","job_id":"1","created_at":1669139262,"token":"sys/token","title":"session title","cache_completed":true}'
    session = BatchConnect::Session.new.from_json(value)
    session.stubs(:completed?).returns(false)
    BatchConnect::Session.stubs(:all).returns([session])

    get '/'

    assert_select 'div.active-sessions-header h3' do |widget_header|
      assert_equal 1, widget_header.size
      assert_equal  true, widget_header.first.text.include?(I18n.t('dashboard.active_sessions_title')), 'Should display the widget title'
      assert_equal  true, widget_header.first.text.include?('(1)'), 'Should display the total number of active sessions'
    end
    assert_select 'div#id_1234 a span', text: 'session title'
  end
end
