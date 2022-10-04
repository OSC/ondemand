require 'test_helper'

class RequestTrackerServiceTest < ActiveSupport::TestCase

  test "should throw exception when queues is not provided" do
    config = {
      rt_api: {
        queues: nil,
        priority: "33",
      }
    }
    Configuration.stubs(:support_ticket_config).returns(config)

    assert_raises(ArgumentError) { RequestTrackerService.new }
  end

  test "should throw exception when priority is not provided" do
    config = {
      rt_api: {
        queues: [ "Standard" ],
        priority: nil,
      }
    }
    Configuration.stubs(:support_ticket_config).returns(config)

    assert_raises(ArgumentError) { RequestTrackerService.new }
  end

  test "create_ticket should run with no errors" do
    config = {
      rt_api: {
        queues: [ "Standard" ],
        priority: "10",
      }
    }
    Configuration.stubs(:support_ticket_config).returns(config)

    support_ticket = SupportTicket.new(email: "email@example.com", cc: "cc@example.com", subject: "Subject")

    mock_rt_client = mock("rt_client")
    mock_rt_client.expects(:create).with do |param_hash|
      param_hash[:Requestor] == support_ticket.email &&
      param_hash[:Cc] == support_ticket.cc &&
      param_hash[:Subject] == support_ticket.subject &&
      param_hash[:Queue] == "Standard" &&
      param_hash[:Priority] == "10"
    end
    .returns("support_ticket_id")

    BatchConnect::Session.stubs(:find).returns(mock("session"))
    RequestTrackerClient.stubs(:create).returns(mock_rt_client)

    result = RequestTrackerService.new.create_ticket(support_ticket)

    assert_equal "support_ticket_id", result
  end

  test "create_ticket should run with no errors when selecting an alternate queue" do
    config = {
      rt_api: {
        queues: [ "Standard", "Alternate" ],
        priority: "10",
      }
    }
    Configuration.stubs(:support_ticket_config).returns(config)

    support_ticket = SupportTicket.new(email: "email@example.com", cc: "cc@example.com", subject: "Subject", queue: "Alternate")

    mock_rt_client = mock("rt_client")
    mock_rt_client.expects(:create).with do |param_hash|
      param_hash[:Requestor] == support_ticket.email &&
      param_hash[:Cc] == support_ticket.cc &&
      param_hash[:Subject] == support_ticket.subject &&
      param_hash[:Queue] == support_ticket.queue &&
      param_hash[:Priority] == "10"
    end
    .returns("support_ticket_id")

    BatchConnect::Session.stubs(:find).returns(mock("session"))
    RequestTrackerClient.stubs(:create).returns(mock_rt_client)

    result = RequestTrackerService.new.create_ticket(support_ticket)

    assert_equal "support_ticket_id", result
  end

  test "create_ticket should raise an error when selecting an invalid queue" do
    config = {
      rt_api: {
        queues: [ "Standard", "Alternate" ],
        priority: "10",
      }
    }
    Configuration.stubs(:support_ticket_config).returns(config)

    support_ticket = SupportTicket.new(email: "email@example.com", cc: "cc@example.com", subject: "Subject", queue: "Not_A_Queue")

    assert_raises(ArgumentError) { RequestTrackerService.new.create_ticket(support_ticket) }

  end
end
