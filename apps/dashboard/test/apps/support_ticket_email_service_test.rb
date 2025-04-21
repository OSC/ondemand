require 'test_helper'

class SupportTicketEmailServiceTest < ActiveSupport::TestCase

  def setup
    config = {
      email: {
        to: 'to_address@support.ticket.com'
      }
    }
    @target = SupportTicketEmailService.new(config)
  end

  test 'deliver_support_ticket should delegate to SupportTicketMailer class and return success message' do
    SupportTicketMailer.expects(:support_email).returns(stub(:deliver_now => nil))
    I18n.stubs(:t).returns('validation message for all support ticket fields')
    I18n.expects(:t).with('dashboard.support_ticket.creation_success', to: 'to_address@support.ticket.com').returns('success message')
    result = @target.deliver_support_ticket(SupportTicket.new)

    assert_equal 'success message', result
  end

  test 'deliver_support_ticket should delegate to SupportTicketMailer class and return success message override when provided' do
    config = {
      email: {
        to: 'to_address@support.ticket.com',
        success_message: 'success message override'
      }
    }
    target = SupportTicketEmailService.new(config)
    SupportTicketMailer.expects(:support_email).returns(stub(:deliver_now => nil))
    result = target.deliver_support_ticket(SupportTicket.new)

    assert_equal 'success message override', result
  end

end