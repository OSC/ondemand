# frozen_string_literal: true

require 'test_helper'

class SupportTicketRtServiceTest < ActiveSupport::TestCase

  def setup
    @target = SupportTicketRtService.new({})
  end

  test 'deliver_support_ticket should delegate to RequestTrackerService class and return success message' do
    RequestTrackerService.expects(:new).returns(stub(:create_ticket => '123'))
    result = @target.deliver_support_ticket(SupportTicket.new)

    assert_equal 'Support ticket created in RequestTracker system. TicketId: 123', result
  end

  test 'deliver_support_ticket should delegate to RequestTrackerService class and return success message override when provided' do
    rt_config = {
      rt_api: {
        success_message: 'success message override'
      }
    }
    target = SupportTicketRtService.new(rt_config)
    RequestTrackerService.expects(:new).returns(stub(:create_ticket => '123'))
    result = target.deliver_support_ticket(SupportTicket.new)

    assert_equal 'success message override', result
  end
end
