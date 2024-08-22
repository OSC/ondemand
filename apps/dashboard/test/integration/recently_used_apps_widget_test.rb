# frozen_string_literal: true

require 'html_helper'
require 'test_helper'

class RecentlyUsedAppsWidgetTest < ActionDispatch::IntegrationTest
  def setup
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/widgets/recently_used_apps/sys'))
    DevRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/widgets/recently_used_apps/dev'))
    UsrRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/widgets/recently_used_apps/usr'))
    BatchConnect::Session.stubs(:cache_root).returns(Rails.root.join('test/fixtures/widgets/recently_used_apps'))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))

    stub_user_configuration(
      {
        dashboard_layout: {
          rows: [{ columns: [{ width: 12, widgets: ['recently_used_apps'] }] }]
        }
      }
    )
  end

  test 'should render recently used widget' do
    get '/'

    assert_select 'div.recently-used-apps-header h4' do |widget_header|
      assert_equal 1, widget_header.size
      assert_equal true, widget_header.first.text.include?(I18n.t('dashboard.recently_used_apps_title')),
                   'Should display the widget title'
    end

    assert_select "div[data-bs-toggle='launcher-button']", 1
    assert_select 'form.button_to', 1
    assert_select 'form.button_to button p.app-title', text: 'Recently Used Sys'
  end

  test 'recently used apps should render the a launcher with a form with the application cached values' do
    get '/'

    assert_select "div[data-bs-toggle='launcher-button']", 1

    assert_select 'form.button_to' do |elements|
      assert_equal 1, elements.size
      assert_equal batch_connect_session_contexts_path(token: 'sys/bc_desktop'), elements[0]['action']
      assert_equal 'post', elements[0]['method']
    end

    recently_used_app = BatchConnect::App.from_token('sys/bc_desktop')
    app_attributes = recently_used_app.attributes
    form_values = {}
    assert_select 'form.button_to input[type="hidden"]' do |elements|
      elements.each do |input|
        form_values[input['name']] = input['value']
      end
    end

    app_attributes.each do |attribute|
      assert_equal true, form_values.key?("batch_connect_session_context[#{attribute.id}]"),
                   "Attribute: #{attribute.id} not in form: #{form_values}"
    end

    assert_equal 'quick', form_values['batch_connect_session_context[cluster]']
    assert_equal '100', form_values['batch_connect_session_context[bc_vnc_idle]']
    assert_equal 'gnome', form_values['batch_connect_session_context[desktop]']
    assert_equal '10', form_values['batch_connect_session_context[bc_num_hours]']
    assert_equal '5', form_values['batch_connect_session_context[bc_num_slots]']
    assert_equal 'big', form_values['batch_connect_session_context[node_type]']
    assert_equal 'account', form_values['batch_connect_session_context[bc_account]']
    assert_equal 'queue', form_values['batch_connect_session_context[bc_queue]']
    assert_equal '10', form_values['batch_connect_session_context[bc_num_hours]']
    assert_equal '1080x754', form_values['batch_connect_session_context[bc_vnc_resolution]']
    assert_equal '1', form_values['batch_connect_session_context[bc_email_on_started]']
  end
end
