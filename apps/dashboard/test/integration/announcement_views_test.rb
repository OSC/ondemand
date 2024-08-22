require 'test_helper'

class AnnouncementViewsTest < ActionDispatch::IntegrationTest
  test 'announcement is displayed if exists' do
    f = Tempfile.open(%w[announcement .md])
    f.write %(Test announcement.)
    f.close

    stub_user_configuration({ announcement_path: [f.path] })

    begin
      get '/'
      assert_response :success
      assert_select 'div.announcement div.announcement-body', 'Test announcement.'
    ensure
      stub_user_configuration({})
    end
  end

  test 'dismissible announcement have a button to close the announcement' do
    file = "#{Rails.root}/test/fixtures/config/announcements/announcement_view.yml"
    stub_user_configuration({ announcement_path: [file] })

    begin
      get '/'
      assert_response :success
      assert_select 'div.announcement div.announcement-body', 'This is the announcement.'
      assert_select 'div.announcement .announcement-button', I18n.t('dashboard.announcements_dismissible_button')
      form = css_select('div.announcement .announcement-form')
      assert_equal 1, form.size
      assert_equal settings_path(action: 'announcement'), form[0]['action']
    ensure
      stub_user_configuration({})
    end
  end
end
