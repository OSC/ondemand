# frozen_string_literal: true

require 'test_helper'

class SupportTicketServiceNowServiceTest < ActiveSupport::TestCase
  def setup
    @target = SupportTicketServiceNowService.new({})
    attachment_mock = stub({ size: 100 })
    @params = {
      username:    'username',
      email:       'test@example.com',
      cc:          'cc@example.com',
      subject:     'support ticket subject',
      description: 'support ticket description',
      attachments: [attachment_mock, attachment_mock],
      session_id:  '123456'
    }
    @session_mock = stub({ title: 'session_title', job_id: '1234', status: 'Running', created_at: nil })
  end

  test 'default_support_ticket should return a SupportTicket model' do
    result = @target.default_support_ticket({})
    assert_equal 'SupportTicket', result.class.name
  end

  test 'default_support_ticket should set a session when session_id provided' do
    BatchConnect::Session.expects(:exist?).with('1234').returns(true)
    BatchConnect::Session.expects(:find).with('1234').returns(@session_mock)
    result = @target.default_support_ticket({ session_id: '1234' })

    assert_equal '1234', result.session_id
    assert_equal 'session_title(1234) - Running - N/A', result.session_description
  end

  test 'validate_support_ticket should return a SupportTicket model' do
    result = @target.validate_support_ticket({})
    assert_equal 'SupportTicket', result.class.name
  end

  test 'validate_support_ticket should set all SupportTicket fields when provided' do
    result = @target.validate_support_ticket(@params)

    assert_equal 'username', result.username
    assert_equal 'test@example.com', result.email
    assert_equal 'cc@example.com', result.cc
    assert_equal 'support ticket subject', result.subject
    assert_equal 'support ticket description', result.description
    assert_equal @params[:attachments], result.attachments
    assert_equal '123456', result.session_id
  end

  test 'validate_support_ticket should set a session when session_id provided' do
    BatchConnect::Session.expects(:exist?).with('1234').returns(true)
    BatchConnect::Session.expects(:find).with('1234').returns(@session_mock)
    result = @target.validate_support_ticket({ session_id: '1234' })

    assert_equal '1234', result.session_id
    assert_equal 'session_title(1234) - Running - N/A', result.session_description
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
