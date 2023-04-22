# frozen_string_literal: true

require 'test_helper'

class RequestTrackerIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    Configuration.stubs(:support_ticket_enabled?).returns(true)
    stub_user_configuration(
      {
        support_ticket: {
          rt_api: {
            queues:   ['queue_name'],
            priority: 10
          }
        }
      }
    )
    Rails.application.reload_routes!
  end

  test 'GET should render support ticket page' do
    get support_path
    assert :success

    assert_select "input[type='hidden'][id='support_ticket_session_id']", 1
    assert_select "input[type='hidden'][id='support_ticket_queue']", 1

    ['username', 'email', 'cc', 'subject'].each do |field_id|
      assert_select "label[for='support_ticket_#{field_id}']", 1
      assert_select "input[id='support_ticket_#{field_id}']", 1
    end
    assert_select "label[for='support_ticket_attachments']", 1
    assert_select "p[id='support_ticket_attachments']", 1
    assert_select "label[for='support_ticket_description']", 1
    assert_select "textarea[id='support_ticket_description']", 1

    assert_select "input[type='submit']", 1
  end

  test 'POST should create support ticket via Request Tracker client' do
    get support_path
    assert :success

    token = css_select("input[type='hidden'][name='authenticity_token']").first['value']
    headers = { 'X-CSRF-Token' => token }

    data = {
      support_ticket: {
        username:    'test',
        email:       'name@domain.com',
        cc:          'cc@domain.com',
        subject:     'test subject',
        description: 'description'
      }
    }
    # Stub request tracker client to avoid the need for a server.
    request_tracker_client = stub('rt_client')
    request_tracker_client.expects(:create).with do |payload|
      assert_equal 'queue_name', payload[:Queue]
      assert_equal 10, payload[:Priority]
      assert_equal 'name@domain.com', payload[:Requestor]
      assert_equal 'test subject', payload[:Subject]
    end.returns('ticket_id')
    RequestTrackerClient.stubs(:new).returns(request_tracker_client)

    post support_path, params: data, headers: headers
    # Success redirects to the homepage with the success message
    follow_redirect!
    assert_response :success
    assert_equal root_path, path
    # Displays success message
    assert_select "div.alert-success[role='alert']", 1
  end
end
