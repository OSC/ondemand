# frozen_string_literal: true

require 'test_helper'

class SupportTicketServiceNowServiceTest < ActiveSupport::TestCase

  def setup
    @target = SupportTicketServiceNowService.new({})
  end

  test 'deliver_support_ticket should generate default payload' do
    support_ticket = SupportTicket.from_config({})
    support_ticket.attributes = {username: 'username', email: 'email@example.com', cc: 'cc@example.com', subject: 'Subject', description: 'Description'}
    mock_client = mock('servicenow_client')
    mock_client.expects(:create).with do |payload|
      payload[:caller_id] == support_ticket.email &&
        payload[:short_description] == support_ticket.subject &&
        payload[:watch_list] == support_ticket.cc &&
        payload[:description].include?('Ticket submitted from OnDemand dashboard application') &&
        payload[:description].include?("Username: #{support_ticket.username}") &&
        payload[:description].include?("Email: #{support_ticket.email}")
    end
    .returns(create_response('incident_number', true))

    ServiceNowClient.expects(:new).returns(mock_client)
    @target.deliver_support_ticket(support_ticket)
  end

  test 'deliver_support_ticket should map form fields to ServiceNow fields based on the configuration map' do
    config = {
      servicenow_api: {
        map: {
          caller_id:         'username',
          short_description: 'description'
        }
      }
    }
    target = SupportTicketServiceNowService.new(config)
    support_ticket = SupportTicket.from_config({})
    support_ticket.attributes = {username: 'username', email: 'email@example.com', subject: 'Subject', description: 'Description'}
    mock_client = mock('servicenow_client')
    mock_client.expects(:create).with do |payload|
      payload[:caller_id] == support_ticket.username &&
        payload[:short_description] == support_ticket.description
    end
    .returns(create_response('incident_number', true))

    ServiceNowClient.expects(:new).returns(mock_client)
    target.deliver_support_ticket(support_ticket)
  end

  test 'map should support arrays of fields' do
    config = {
      servicenow_api: {
        map: {
          watch_list: ['username', 'email', 'cc'],
        }
      }
    }
    target = SupportTicketServiceNowService.new(config)
    support_ticket = SupportTicket.from_config({})
    support_ticket.attributes = {username: 'username', email: 'email@example.com', subject: 'Subject', description: 'Description'}
    mock_client = mock('servicenow_client')
    mock_client.expects(:create).with do |payload|
      # cc is nil, so it should only be username and email
      payload[:watch_list] == 'username,email@example.com'
    end
    .returns(create_response('incident_number', true))

    ServiceNowClient.expects(:new).returns(mock_client)
    target.deliver_support_ticket(support_ticket)
  end

  test 'deliver_support_ticket should add custom payload fields based on the configuration payload' do
    config = {
      servicenow_api: {
        payload: {
          caller_id:         'custom_caller_id',
          short_description: 'custom_short_description',
          contact_type:      'External System',
          assignment_group:  'Group A'
        }
      }
    }
    target = SupportTicketServiceNowService.new(config)
    support_ticket = SupportTicket.from_config({})
    support_ticket.attributes = {username: 'username', email: 'email@example.com', subject: 'Subject', description: 'Description'}
    mock_client = mock('servicenow_client')
    mock_client.expects(:create).with do |payload|
      payload[:caller_id] == 'custom_caller_id' &&
        payload[:short_description] == 'custom_short_description' &&
        payload[:contact_type] == 'External System' &&
        payload[:assignment_group] == 'Group A'
    end
    .returns(create_response('incident_number', true))

    ServiceNowClient.expects(:new).returns(mock_client)
    target.deliver_support_ticket(support_ticket)
  end

  test 'deliver_support_ticket should delegate to ServiceNowClient class and return success message' do
    ServiceNowClient.expects(:new).returns(stub(:create => create_response('123')))
    result = @target.deliver_support_ticket(SupportTicket.new)

    assert_equal 'Support ticket created in ServiceNow. Number: 123', result
  end

  test 'deliver_support_ticket should delegate to ServiceNowClient class and return failure message when errors with attachments' do
    ServiceNowClient.expects(:new).returns(stub(:create => create_response('3456', false)))
    result = @target.deliver_support_ticket(SupportTicket.new)

    assert_equal 'Support ticket created in ServiceNow. Number: 3456. But unable to add the attachments.', result
  end

  test 'deliver_support_ticket should delegate to ServiceNowClient class and return success message override when provided' do
    rt_config = {
      servicenow_api: {
        success_message: 'success message override'
      }
    }
    target = SupportTicketServiceNowService.new(rt_config)
    ServiceNowClient.expects(:new).returns(stub(:create => create_response('123')))
    result = target.deliver_support_ticket(SupportTicket.new)

    assert_equal 'success message override', result
  end

  def create_response(number, attachments_success = true)
    OpenStruct.new({
     number:              number,
     attachments:         1,
     attachments_success: attachments_success
   })
  end
end
