# frozen_string_literal: true

require 'html_helper'
require 'test_helper'

class NsfAccessAnnouncementsWidgetTest < ActionDispatch::IntegrationTest
  def setup
    stub_user_configuration({
      dashboard_layout: {
        rows: [{ columns: [{ width: 12, widgets: ['nsf_access_announcements'] }] }]
      }
    })
  end

  test 'should render nsf access announcements widget' do
    get '/'

    assert_response :success
    assert_select 'div.h2', text: I18n.t('dashboard.nsf_access_announcements')
    assert_select 'div#nsf_access_announcements.spinner-border[role=status]', 1
    assert_select 'div#nsf_access_announcements span.visually-hidden', text: 'Loading...'
  end
end
