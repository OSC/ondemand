require 'test_helper'

class SupportTicketIntegrationTest < ActionDispatch::IntegrationTest

  def setup
    Configuration.stubs(:support_ticket_enabled?).returns(true)
    Configuration.stubs(:support_ticket_config).returns({
      email: {
        to: "to_address@support.ticket.com",
      }
    })
    Rails.application.routes.append do
      get "/support", to: "support_ticket#new"
      post "/support", to: "support_ticket#create"
    end
    Rails.application.reload_routes!
  end

  test "GET should render support ticket page" do
    get support_path
    assert :success

    assert_select "input[type='text'][id='username']", 1

    ["username", "email", "cc", "subject"].each do |field_id|
      assert_select "label[for='#{field_id}']", 1
      assert_select "input[id='#{field_id}']", 1
    end
    assert_select "label[for='attachments']", 1
    assert_select "label[for='description']", 1
    assert_select "textarea[id='description']", 1

    assert_select "input[type='submit']", 1

    doc = Nokogiri::XML(@response.body)
    @token = doc.xpath("/html/head/meta[@name='csrf-token']/@content").to_s
    @headers = { 'X-CSRF-Token' => @token }
  end

  test "POST should should create support ticket via email" do
    get support_path
    assert :success

    token = css_select("input[type='hidden'][name='authenticity_token']").first['value']
    headers = { 'X-CSRF-Token' => token }
    number_of_emails = ActionMailer::Base.deliveries.size

    data = {
      support_ticket: {
        username: "test",
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
      assert_equal ["to_address@support.ticket.com"], email.to
      assert_equal ["name@domain.com"], email.from
      assert_equal ["name@domain.com"], email.reply_to
      assert_equal ["cc@domain.com"], email.cc
      assert_equal "test subject", email.subject
      assert_match 'description', email.body.encoded
    end

  end


end