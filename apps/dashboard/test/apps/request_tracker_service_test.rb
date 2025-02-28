require 'test_helper'

class RequestTrackerServiceTest < ActiveSupport::TestCase

  test "should throw exception when queues is not provided" do
    config = {
      queues: nil,
      priority: "33",
    }

    assert_raises(ArgumentError) { RequestTrackerService.new(config) }
  end

  test "should throw exception when priority is not provided" do
    config = {
      queues: [ "Standard" ],
      priority: nil,
    }

    assert_raises(ArgumentError) { RequestTrackerService.new(config) }
  end

  test "create_ticket should run with no errors" do
    config = {
      queues: [ "Standard" ],
      priority: "10",
    }

    support_ticket = SupportTicket.from_config({})
    support_ticket.attributes = {email: "email@example.com", cc: "cc@example.com", subject: "Subject"}

    mock_rt_client = mock("rt_client")
    mock_rt_client.expects(:create).with do |param_hash|
      param_hash[:Requestor] == support_ticket.email &&
      param_hash[:Cc] == support_ticket.cc &&
      param_hash[:Subject] == support_ticket.subject &&
      param_hash[:Queue] == "Standard" &&
      param_hash[:Priority] == "10" &&
      param_hash[:Text].include?('"id": "session_id"') &&
      param_hash[:Text].include?('"id": "job_id"')
    end
    .returns("support_ticket_id")

    session = BatchConnect::Session.new(id: 'session_id', created_at: Time.now)
    job = OodCore::Job::Info.new(id: 'job_id', status: 'running')
    RequestTrackerClient.stubs(:new).returns(mock_rt_client)

    result = RequestTrackerService.new(config).create_ticket(support_ticket, session, job)

    assert_equal "support_ticket_id", result
  end

  test "create_ticket should run with no errors when selecting an alternate queue" do
    config = {
      queues: [ "Standard", "Alternate" ],
      priority: "10",
    }

    support_ticket = SupportTicket.from_config({})
    support_ticket.attributes = {email: "email@example.com", cc: "cc@example.com", subject: "Subject", queue: "Alternate"}

    mock_rt_client = mock("rt_client")
    mock_rt_client.expects(:create).with do |param_hash|
      param_hash[:Requestor] == support_ticket.email &&
      param_hash[:Cc] == support_ticket.cc &&
      param_hash[:Subject] == support_ticket.subject &&
      param_hash[:Queue] == support_ticket.queue &&
      param_hash[:Priority] == "10"
    end
    .returns("support_ticket_id")

    session = BatchConnect::Session.new(id: 'session', created_at: Time.now)
    job = OodCore::Job::Info.new(id: '12345', status: 'running')
    RequestTrackerClient.stubs(:new).returns(mock_rt_client)

    result = RequestTrackerService.new(config).create_ticket(support_ticket, session, job)

    assert_equal "support_ticket_id", result
  end

  test "create_ticket should raise an error when selecting an invalid queue" do
    config = {
      queues: [ "Standard", "Alternate" ],
      priority: "10",
    }

    support_ticket = SupportTicket.from_config({})
    support_ticket.attributes = {email: "email@example.com", cc: "cc@example.com", subject: "Subject", queue: "Not_A_Queue"}
    session = BatchConnect::Session.new(id: 'session', created_at: Time.now)
    job = OodCore::Job::Info.new(id: '12345', status: 'running')

    assert_raises(ArgumentError) { RequestTrackerService.new(config).create_ticket(support_ticket, session, job) }

  end
end
