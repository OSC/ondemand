require "test_helper"

class SupportTicketMailerTest < ActionMailer::TestCase

  def setup
    Configuration.stubs(:support_ticket_config).returns({
      email: {
        to: "to_address@support.ticket.com",
      }
    })

    @support_ticket = SupportTicket.from_config({})
    @support_ticket.attributes = {
      email: "user_email@example.com",
      cc: "cc@example.com",
      subject: "email subject",
    }
    @context = OpenStruct.new({
      support_ticket: @support_ticket,
    })
  end

  test 'generates email with all expected fields' do
    email = SupportTicketMailer.support_email(@context)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["user_email@example.com"], email.from
    assert_equal ["to_address@support.ticket.com"], email.to
    assert_equal ["user_email@example.com"], email.reply_to
    assert_equal ["cc@example.com"], email.cc
    assert_equal "email subject", email.subject
    assert_match 'Support ticket submitted from the dashboard application', email.body.encoded
  end

  test 'from address can be overridden with configuration' do
    Configuration.stubs(:support_ticket_config).returns({
      email: {
        from: "override@example.com",
        to: "to_address@support.ticket.com",
      }
    })
    email = SupportTicketMailer.support_email(@context)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["override@example.com"], email.from
  end

end