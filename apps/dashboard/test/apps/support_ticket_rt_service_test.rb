require "test_helper"

class SupportTicketRtServiceTest < ActiveSupport::TestCase

  def setup
    @target = SupportTicketRtService.new({})
    attachment_mock = stub({size: 100})
    @params = {
      username: "username",
      email: "test@example.com",
      cc: "cc@example.com",
      subject: "support ticket subject",
      description: "support ticket description",
      attachments: [attachment_mock, attachment_mock],
      session_id: "123456",
      queue: "General"
    }
    @session_mock = stub({title: 'session_title', job_id: '1234', status: "Running", created_at: nil})
  end

  test "default_support_ticket should return a SupportTicket model" do
    result = @target.default_support_ticket({})
    assert_equal "SupportTicket", result.class.name
  end

  test "default_support_ticket should set a session when session_id provided" do
    BatchConnect::Session.expects(:exist?).with("1234").returns(true)
    BatchConnect::Session.expects(:find).with("1234").returns(@session_mock)
    result = @target.default_support_ticket({session_id: "1234"})

    assert_equal "1234", result.session_id
    assert_equal 'session_title(1234) - Running - N/A', result.session_description
  end

  test "default_support_ticket should set queue when provided" do
    result = @target.default_support_ticket({queue: "queue_name"})

    assert_equal "queue_name", result.queue
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
    assert_equal "General", result.queue
  end

  test "validate_support_ticket should set a session when session_id provided" do
    BatchConnect::Session.expects(:exist?).with("1234").returns(true)
    BatchConnect::Session.expects(:find).with("1234").returns(@session_mock)
    result = @target.validate_support_ticket({session_id: "1234"})

    assert_equal "1234", result.session_id
    assert_equal 'session_title(1234) - Running - N/A', result.session_description
  end

  test "deliver_support_ticket should delegate to RequestTrackerService class and return success message" do
    RequestTrackerService.expects(:new).returns(stub(:create_ticket => "123"))
    result = @target.deliver_support_ticket(SupportTicket.new)

    assert_equal "Support ticket created in RequestTracker system. TicketId: 123", result
  end

  test "deliver_support_ticket should delegate to RequestTrackerService class and return success message override when provided" do
    rt_config = {
      rt_api: {
          success_message: "success message override"
        }
    }
    target = SupportTicketRtService.new(rt_config)
    RequestTrackerService.expects(:new).returns(stub(:create_ticket => "123"))
    result = target.deliver_support_ticket(SupportTicket.new)

    assert_equal "success message override", result
  end

end