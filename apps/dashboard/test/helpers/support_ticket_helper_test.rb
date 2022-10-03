require 'test_helper'

class SupportTicketHelperTest < ActionView::TestCase

  include SupportTicketHelper

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

  test "support_ticket_has_error? should check if a field has errors" do
    @valid_hash[:email] = nil
    @valid_hash[:cc] = "invalid_email"
    @support_ticket = SupportTicket.new(@valid_hash)
    @support_ticket.validate

    assert_equal true, support_ticket_has_error?(:email)
    assert_equal true, support_ticket_has_error?(:cc)
    assert_equal false, support_ticket_has_error?(:subject)
    assert_equal false, support_ticket_has_error?(:description)
  end

  test "support_ticket_add_error_class should be has-error when field has errors" do
    @valid_hash[:email] = nil
    @valid_hash[:cc] = "invalid_email"
    @support_ticket = SupportTicket.new(@valid_hash)
    @support_ticket.validate

    assert_equal "has-error", support_ticket_add_error_class(:email)
    assert_equal "has-error", support_ticket_add_error_class(:cc)
    assert_nil support_ticket_add_error_class(:subject)
    assert_nil support_ticket_add_error_class(:description)
  end

  test "filter_session_parameters should filter known parameters" do
    known_parameters = ["ood_connection_info"]
    expected_session_parameters = {
      "job_name": "job",
      "job_owner": "owner",
      "accounting_id": "account",
      "procs": "process",
      "queue_name": "queue",
    }

    known_parameters.each do |parameter|
      session_info = expected_session_parameters.clone
      session_info[parameter]= {}
      assert_equal expected_session_parameters, filter_session_parameters(session_info)
    end
  end

end
