# frozen_string_literal: true

require 'html_helper'
require 'test_helper'

class SavedSettingsWidgetTest < ActionDispatch::IntegrationTest
  def setup
    stub_sys_apps

    stub_user_configuration(
      {
        dashboard_layout: {
          rows: [{ columns: [{ width: 12, widgets: ['saved_settings'] }] }]
        }
      }
    )
  end

  test 'should not render saved settings widget when no saved settings' do
    get '/'

    assert_select 'div.settings-widget h3', 0
  end

  test 'should render saved settings widget' do
    stub_user_settings

    get '/'

    assert_select 'div.settings-widget h3' do |widget_header|
      assert_equal 1, widget_header.size
      assert_equal true, widget_header.first.text.include?(I18n.t('dashboard.saved_settings_title')),
                   'Should display the widget title'

      saved_setting_link = css_select('div.settings-widget div.h5.card-header a.saved-settings-show')
      assert_equal 1, saved_setting_link.size
      assert_equal 'widget_name', saved_setting_link.first.text.strip
      assert_equal batch_connect_setting_path(token: 'sys/bc_paraview', id: 'widget_name'), saved_setting_link.first['href']

      assert_equal 'Paraview', css_select('div.settings-widget span.list-group-item.header').text.strip
    end
  end

  def stub_user_settings
    file = "#{Rails.root}/test/fixtures/file_output/user_settings/saved_settings_widget.yml"
    Configuration.stubs(:user_settings_file).returns(file)
  end
end
