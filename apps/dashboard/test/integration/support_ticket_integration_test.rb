require 'test_helper'

class SupportTicketIntegrationTest < ActionDispatch::IntegrationTest

  def setup
    Configuration.stubs(:support_ticket_enabled?).returns(true)
    stub_user_configuration(
      {
        support_ticket: {
          email: {
            to: 'to_address@support.ticket.com',
            delivery_method: 'test'
          }
        }
      })
    Rails.application.reload_routes!
  end

  test 'GET should render support ticket page' do
    get support_path
    assert :success

    assert_select "input[type='hidden'][id='support_ticket_session_id']", 1
    assert_select "input[type='hidden'][id='support_ticket_queue']", 1

    ["username", "email", "cc", "subject"].each do |field_id|
      assert_select "label[for='support_ticket_#{field_id}']", 1
      assert_select "input[id='support_ticket_#{field_id}']", 1
    end
    assert_select "label[for='support_ticket_attachments']", 1
    assert_select "p[id='support_ticket_attachments']", 1
    assert_select "label[for='support_ticket_description']", 1
    assert_select "textarea[id='support_ticket_description']", 1

    assert_select "input[type='submit']", 1
  end

  test 'POST should should create support ticket via email' do
    get support_path
    assert :success

    token = css_select("input[type='hidden'][name='authenticity_token']").first['value']
    headers = { 'X-CSRF-Token' => token }
    number_of_emails = ActionMailer::Base.deliveries.size

    data = {
      support_ticket: {
        username: 'test',
        email: 'name@domain.com',
        cc: 'cc@domain.com',
        subject: 'test subject',
        description: 'description'
      }
    }
    post support_path, params: data, headers: headers
    # Success redirects to the homepage with the success message
    follow_redirect!
    assert_response :success
    assert_equal root_path, path
    # Displays success message
    assert_select "div.alert-success[role='alert']", 1

    # A new email was sent
    assert_equal number_of_emails + 1, ActionMailer::Base.deliveries.size
    # Check email details
    ActionMailer::Base.deliveries.last.tap do |email|
      assert_equal ['to_address@support.ticket.com'], email.to
      assert_equal ['name@domain.com'], email.from
      assert_equal ['name@domain.com'], email.reply_to
      assert_equal ['cc@domain.com'], email.cc
      assert_equal 'test subject', email.subject
      assert_match 'description', email.body.encoded
      assert_match 'Session Information:', email.body.encoded
      assert_match 'Job Information:', email.body.encoded
    end

  end


end