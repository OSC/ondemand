require 'test_helper'

class SupportTicketTest < ActiveSupport::TestCase

  def setup
    attachment_mock = stub({size: 100})
    @valid_hash = {
      username: "username",
      email: "test@example.com",
      cc: "cc@example.com",
      subject: "support ticket subject",
      description: "support ticket description",
      attachments: [attachment_mock, attachment_mock],
      session_id: "123456"
    }
  end

  test "sets all fields from hash and is valid" do
    target = SupportTicket.new(@valid_hash)

    assert_equal "username", target.username
    assert_equal "test@example.com", target.email
    assert_equal "cc@example.com", target.cc
    assert_equal "support ticket subject", target.subject
    assert_equal "support ticket description", target.description
    assert_equal @valid_hash[:attachments], target.attachments
    assert_equal "123456", target.session_id

    assert_equal true, target.valid?
  end

  test "username is required" do
    @valid_hash[:username] = nil
    target = SupportTicket.new(@valid_hash)

    assert_equal false, target.valid?
    assert_equal false, target.errors[:username].blank?
    puts target.errors
  end

  test "email is required" do
    @valid_hash[:email] = nil
    target = SupportTicket.new(@valid_hash)

    assert_equal false, target.valid?
    assert_equal false, target.errors[:email].blank?
  end

  test "email should be an email address" do
    @valid_hash[:email] = "no_email"
    target = SupportTicket.new(@valid_hash)

    assert_equal false, target.valid?
    assert_equal false, target.errors[:email].blank?
  end

  test "cc should be an email address if provided" do
    @valid_hash[:cc] = "no_email"
    target = SupportTicket.new(@valid_hash)

    assert_equal false, target.valid?
    assert_equal false, target.errors[:cc].blank?
  end

  test "subject is required" do
    @valid_hash[:subject] = nil
    target = SupportTicket.new(@valid_hash)

    assert_equal false, target.valid?
    assert_equal false, target.errors[:subject].blank?
  end

  test "description is required" do
    @valid_hash[:description] = nil
    target = SupportTicket.new(@valid_hash)

    assert_equal false, target.valid?
    assert_equal false, target.errors[:description].blank?
  end

  test "only 4 attachments are allowed" do
    attachment_mock = stub({size: 100})
    @valid_hash[:attachments] = [attachment_mock, attachment_mock, attachment_mock, attachment_mock, attachment_mock]
    target = SupportTicket.new(@valid_hash)

    assert_equal false, target.valid?
    assert_equal false, target.errors[:attachments].blank?
  end

  test "attachments size should be smaller than 6MB" do
    #10MB = 10485760
    attachment_mock = stub({size: 10485760})
    @valid_hash[:attachments] = [attachment_mock]
    target = SupportTicket.new(@valid_hash)

    assert_equal false, target.valid?
    assert_equal false, target.errors[:attachments].blank?
  end

end