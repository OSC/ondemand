# frozen_string_literal: true

require 'application_system_test_case'

# Very similar to preset_apps_navbar_test.rb only in that there are
# Pinned apps that _have_ to be stubbed in setup. If these files were combined,
# you wouldn't be able to tell what's the navbar entry and which is the pinned app
class PresetAppsPinnedTest < ApplicationSystemTestCase
  def setup
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/apps'))
    stub_user_configuration({ pinned_apps: ['sys/preset_app/*'] })
    BatchConnect::Session.any_instance.stubs(:stage).raises(StandardError.new(err_msg))
    Router.instance_variable_set('@pinned_apps', nil)
  end

  def teardown
    Router.instance_variable_set('@pinned_apps', nil)
  end

  def err_msg
    'This is just a test'
  end

  def err_header
    'save'
  end

  test 'preset apps in pinned apps directly launch' do
    visit root_path
    click_on 'Test App: Preset'
    sleep 1.5
    verify_bc_alert('sys/preset_app/preset', err_header, err_msg)
  end

  test 'choice apps in pinned apps still redirect to the form' do
    visit root_path
    click_on 'Test App: Choice'

    # we can click the launch button and it does the same thing as above.
    assert_equal new_batch_connect_session_context_path('sys/preset_app/choice'), current_path
    click_on 'Launch'

    sleep 1.5
    verify_bc_alert('sys/preset_app/choice', err_header, err_msg)
  end
end
