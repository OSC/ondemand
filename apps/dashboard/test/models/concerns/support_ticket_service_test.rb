# frozen_string_literal: true

require 'test_helper'

class SupportTicketServiceTest < ActionView::TestCase
  include SupportTicketService

  def setup
    attachment_mock = stub({ size: 100 })
    @params = {
      username:    'username',
      email:       'test@example.com',
      cc:          'cc@example.com',
      subject:     'support ticket subject',
      description: 'support ticket description',
      attachments: [attachment_mock, attachment_mock],
      session_id:  '123456',
      job_id:      '99123',
      cluster:     'test_cluster'
    }

    @session_mock = stub({ title: 'session_title', job_id: '1234', status: 'Running', created_at: nil })
    @job_mock = stub({ id: '99123', status: 'running', submission_time: nil })
  end

  def support_ticket_config
    {}
  end

  test 'default_support_ticket should return a SupportTicket model' do
    result = default_support_ticket({})
    assert_equal 'SupportTicket', result.class.name
  end

  test 'default_support_ticket should set session_description when session_id provided' do
    BatchConnect::Session.expects(:exist?).with('1234').returns(true)
    BatchConnect::Session.expects(:find).with('1234').returns(@session_mock)
    result = default_support_ticket({session_id: '1234'})

    assert_equal '1234', result.session_id
    assert_equal 'session_title(1234) - Running - N/A', result.session_description
  end

  test 'default_support_ticket should set job_description when job_id and cluster provided' do
    cluster = stub({ job_adapter: stub({ info: @job_mock }) })
    OODClusters.expects(:[]).with(:test_cluster).returns(cluster)
    result = default_support_ticket({ job_id: '99123', cluster: 'test_cluster' })

    assert_equal '99123', result.job_id
    assert_equal 'test_cluster', result.cluster
    assert_equal 'Job: 99123 - running - N/A', result.job_description
  end

  test 'validate_support_ticket should return a SupportTicket model' do
    result = validate_support_ticket({})
    assert_equal 'SupportTicket', result.class.name
  end

  test 'validate_support_ticket should set all SupportTicket fields when provided' do
    result = validate_support_ticket(@params)

    assert_equal 'username', result.username
    assert_equal 'test@example.com', result.email
    assert_equal 'cc@example.com', result.cc
    assert_equal 'support ticket subject', result.subject
    assert_equal 'support ticket description', result.description
    assert_equal @params[:attachments], result.attachments
    assert_equal '123456', result.session_id
    assert_equal '99123', result.job_id
    assert_equal 'test_cluster', result.cluster
  end

  test 'validate_support_ticket should set session_description when session_id provided' do
    BatchConnect::Session.expects(:exist?).with('1234').returns(true)
    BatchConnect::Session.expects(:find).with('1234').returns(@session_mock)
    result = validate_support_ticket({ session_id: '1234' })

    assert_equal '1234', result.session_id
    assert_equal 'session_title(1234) - Running - N/A', result.session_description
  end

  test 'validate_support_ticket should set job_description when job_id and cluster provided' do
    cluster = stub({ job_adapter: stub({ info: @job_mock }) })
    OODClusters.expects(:[]).with(:osc_cluster).returns(cluster)
    result = validate_support_ticket({ job_id: '99123', cluster: 'osc_cluster' })

    assert_equal '99123', result.job_id
    assert_equal 'osc_cluster', result.cluster
    assert_equal 'Job: 99123 - running - N/A', result.job_description
  end

  test 'validate_support_ticket should set errors if any' do
    result = validate_support_ticket({})

    assert_equal false, result.errors.empty?
    assert_equal false, result.errors['username'].blank?
    assert_equal false, result.errors['email'].blank?
    assert_equal false, result.errors['subject'].blank?
    assert_equal false, result.errors['description'].blank?
  end

end
