require "test_helper"

class SupportTicketEmailServiceTest < ActiveSupport::TestCase

  def setup
    config = {
      email: {
        to: "to_address@support.ticket.com"
      }
    }
    @target = SupportTicketEmailService.new(config)
    attachment_mock = stub({size: 100})
    @params = {
      username: "username",
      email: "test@example.com",
      cc: "cc@example.com",
      subject: "support ticket subject",
      description: "support ticket description",
      attachments: [attachment_mock, attachment_mock],
      session_id: "123456"
    }

    @session_mock = stub({title: 'session_title', job_id: '1234', status: "Running", created_at: nil})
  end

  test "default_support_ticket should return a SupportTicket model" do
    result = @target.default_support_ticket({})
    assert_equal "SupportTicket", result.class.name
  end

  test "default_support_ticket should set session_description when session_id provided" do
    BatchConnect::Session.expects(:exist?).with("1234").returns(true)
    BatchConnect::Session.expects(:find).with("1234").returns(@session_mock)
    result = @target.default_support_ticket({session_id: "1234"})

    assert_equal "1234", result.session_id
    assert_equal 'session_title(1234) - Running - N/A', result.session_description
  end

  test "validate_support_ticket should return a SupportTicket model" do
    result = @target.validate_support_ticket({})
    assert_equal "SupportTicket", result.class.name
  end

  test "validate_support_ticket should set all SupportTicket fields when provided" do
    result = @target.validate_support_ticket(@params)

    assert_equal "username", result.username
    assert_equal "test@example.com", result.email
    assert_equal "cc@example.com", result.cc
    assert_equal "support ticket subject", result.subject
    assert_equal "support ticket description", result.description
    assert_equal @params[:attachments], result.attachments
    assert_equal "123456", result.session_id
  end

  test "validate_support_ticket should set session_description when session_id provided" do
    BatchConnect::Session.expects(:exist?).with("1234").returns(true)
    BatchConnect::Session.expects(:find).with("1234").returns(@session_mock)
    result = @target.validate_support_ticket({session_id: "1234"})

    assert_equal "1234", result.session_id
    assert_equal 'session_title(1234) - Running - N/A', result.session_description
  end

  test "validate_support_ticket should set errors if any" do
    result = @target.validate_support_ticket({})

    assert_equal false, result.errors.empty?
    assert_equal false, result.errors['username'].blank?
    assert_equal false, result.errors['email'].blank?
    assert_equal false, result.errors['subject'].blank?
    assert_equal false, result.errors['description'].blank?

  end

  test "deliver_support_ticket should delegate to SupportTicketMailer class and return success message" do
    SupportTicketMailer.expects(:support_email).returns(stub(:deliver_now => nil))
    I18n.stubs(:t).returns("validation message for all support ticket fields")
    I18n.expects(:t).with('dashboard.support_ticket.creation_success', {to: "to_address@support.ticket.com"}).returns("success message")
    result = @target.deliver_support_ticket(SupportTicket.new)

    assert_equal "success message", result
  end

  test "deliver_support_ticket should delegate to SupportTicketMailer class and return success message override when provided" do
    config = {
      email: {
        to: "to_address@support.ticket.com",
        success_message: "success message override"
      }
    }
    target = SupportTicketEmailService.new(config)
    SupportTicketMailer.expects(:support_email).returns(stub(:deliver_now => nil))
    result = target.deliver_support_ticket(SupportTicket.new)

    assert_equal "success message override", result
  end

end