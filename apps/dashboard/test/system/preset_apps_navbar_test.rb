# frozen_string_literal: true

require 'application_system_test_case'

class PresetAppsNavbarTest < ApplicationSystemTestCase
  def setup
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/apps'))
    BatchConnect::Session.any_instance.stubs(:stage).raises(StandardError.new(err_msg))
  end

  def err_msg
    'This is just a test'
  end

  def err_header
    'save'
  end

  # the best we can do in this test is stub out BatchConnect::Session#stage
  # and verify that the error we threw is on the page. The link at least tries to submit.
  # TODO: get enough stubs to submit the job and get a 'queued' card to show
  test 'preset apps in navbars auto launch' do
    visit root_path
    click_on 'Interactive Apps'
    click_on 'Test App: Preset'

    sleep 1.5
    verify_bc_alert('sys/preset_app/preset', err_header, err_msg)
  end

  test 'choice apps in navbar still redirect to the form' do
    visit root_path
    click_on 'Interactive Apps'
    click_on 'Test App: Choice'

    # we can click the launch button and it does the same thing as above.
    assert_equal new_batch_connect_session_context_path('sys/preset_app/choice'), current_path
    click_on 'Launch'

    sleep 1.5
    verify_bc_alert('sys/preset_app/choice', err_header, err_msg)
  end
end
