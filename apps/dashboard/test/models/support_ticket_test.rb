# frozen_string_literal: true
require 'test_helper'

class SupportTicketTest < ActiveSupport::TestCase

  def setup
    attachment_mock = stub({size: 100})
    @valid_hash = {
      username: 'username',
      email: 'test@example.com',
      cc: 'cc@example.com',
      subject: 'support ticket subject',
      description: 'support ticket description',
      attachments: [attachment_mock, attachment_mock],
      session_id: '123456',
      session_description: 'session description',
      job_id: '987654',
      cluster: 'cluster',
      job_description: 'job description',
      queue: 'queue_name'
    }
  end

  test 'configures default fields' do
    target = SupportTicket.from_config({})
    assert_equal %w[username email cc subject session_id session_description job_id cluster job_description attachments description queue], target.attributes.map(&:id)
  end

  test 'sets all fields from hash and is valid' do
    target = SupportTicket.from_config({})
    target.attributes = @valid_hash

    assert_equal 'username', target.username
    assert_equal 'test@example.com', target.email
    assert_equal 'cc@example.com', target.cc
    assert_equal 'support ticket subject', target.subject
    assert_equal 'support ticket description', target.description
    assert_equal @valid_hash[:attachments], target.attachments
    assert_equal '123456', target.session_id
    assert_equal 'session description', target.session_description
    assert_equal '987654', target.job_id
    assert_equal 'cluster', target.cluster
    assert_equal 'job description', target.job_description
    assert_equal 'queue_name', target.queue

    assert_equal true, target.valid?
    assert_equal true, target.errors.empty?
  end

  test 'configures custom fields' do
    config = {
      form: ['email', 'custom1', 'custom2']
    }
    target = SupportTicket.from_config(config)
    assert_equal ['email', 'custom1', 'custom2'], target.attributes.map(&:id)
  end

  test 'username is required' do
    @valid_hash[:username] = nil
    target = SupportTicket.from_config({})
    target.attributes = @valid_hash

    assert_equal false, target.valid?
    assert_equal false, target.errors[:username].blank?
  end

  test 'email is required' do
    @valid_hash[:email] = nil
    target = SupportTicket.from_config({})
    target.attributes = @valid_hash

    assert_equal false, target.valid?
    assert_equal false, target.errors[:email].blank?
  end

  test 'email should be an email address' do
    @valid_hash[:email] = 'no_email'
    target = SupportTicket.from_config({})
    target.attributes = @valid_hash

    assert_equal false, target.valid?
    assert_equal false, target.errors[:email].blank?
  end

  test 'cc should be an email address if provided' do
    @valid_hash[:cc] = 'no_email'
    target = SupportTicket.from_config({})
    target.attributes = @valid_hash

    assert_equal false, target.valid?
    assert_equal false, target.errors[:cc].blank?
  end

  test 'subject is required' do
    @valid_hash[:subject] = nil
    target = SupportTicket.from_config({})
    target.attributes = @valid_hash

    assert_equal false, target.valid?
    assert_equal false, target.errors[:subject].blank?
  end

  test 'description is required' do
    @valid_hash[:description] = nil
    target = SupportTicket.from_config({})
    target.attributes = @valid_hash

    assert_equal false, target.valid?
    assert_equal false, target.errors[:description].blank?
  end

  test 'only 4 attachments are allowed by default' do
    attachment_mock = stub({size: 100})
    @valid_hash[:attachments] = [attachment_mock, attachment_mock, attachment_mock, attachment_mock, attachment_mock]
    target = SupportTicket.from_config({})
    target.attributes = @valid_hash

    assert_equal false, target.valid?
    assert_equal false, target.errors[:attachments].blank?
  end

  test 'attachments size should be smaller than 6MB by default' do
    #10MB = 10485760
    attachment_mock = stub({size: 10_485_760})
    @valid_hash[:attachments] = [attachment_mock]
    target = SupportTicket.from_config({})
    target.attributes = @valid_hash

    assert_equal false, target.valid?
    assert_equal false, target.errors[:attachments].blank?
  end

  test 'validate default restrictions' do
    target = SupportTicket.from_config({})

    assert_equal 6_291_456, target.restrictions[:max_size]
    assert_equal 4, target.restrictions[:max_items]
  end

  test 'restrictions should be overridden from configuration' do
    target = SupportTicket.from_config({attachments: {max_size: 1234, max_items: 100}})

    assert_equal 1234, target.restrictions[:max_size]
    assert_equal 100, target.restrictions[:max_items]
  end

end