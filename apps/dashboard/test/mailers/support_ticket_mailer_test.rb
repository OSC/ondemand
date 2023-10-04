# frozen_string_literal: true

require 'test_helper'

class SupportTicketMailerTest < ActionMailer::TestCase
  def setup
    @support_ticket = SupportTicket.from_config({})
    @support_ticket.attributes = {
      email:   'user_email@example.com',
      cc:      'cc@example.com',
      subject: 'email subject'
    }
    @context = OpenStruct.new({
                                support_ticket: @support_ticket
                              })
  end

  test 'generates email with all expected fields' do
    support_ticket_config = {
      email: {
        to: 'to_address@support.ticket.com'
      }
    }
    email = SupportTicketMailer.support_email(support_ticket_config, @context)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['user_email@example.com'], email.from
    assert_equal ['to_address@support.ticket.com'], email.to
    assert_equal ['user_email@example.com'], email.reply_to
    assert_equal ['cc@example.com'], email.cc
    assert_equal 'email subject', email.subject
    assert_match 'Support ticket submitted from the dashboard application', email.body.encoded
  end

  test 'from address can be overridden with configuration' do
    support_ticket_config = {
      email: {
        from: 'override@example.com',
        to:   'to_address@support.ticket.com'
      }
    }
    email = SupportTicketMailer.support_email(support_ticket_config, @context)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['override@example.com'], email.from
  end
end
