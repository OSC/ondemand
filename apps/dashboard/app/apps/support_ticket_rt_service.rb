# frozen_string_literal: true

# Service class responsible to create a support ticket and delivery it via request tracker API
#
# It implements the support ticket interface as defined in the SupportTicketController
class SupportTicketRtService
  include SupportTicketService

  attr_reader :support_ticket_config

  # Constructor
  #
  # @param [Hash] support_ticket_config Support ticket configuration
  def initialize(support_ticket_config)
    @support_ticket_config = support_ticket_config
  end

  # Creates a support ticket in the request tracker system configured
  #
  # @param [SupportTicket] support_ticket support ticket created in validate_support_ticket
  #
  # @return [String] success message
  def deliver_support_ticket(support_ticket)
    service_config = support_ticket_config.fetch(:rt_api, {})
    session = get_session(support_ticket)
    job = get_job(support_ticket)
    rts = RequestTrackerService.new(service_config)
    ticket_id = rts.create_ticket(support_ticket, session, job)
    service_config.fetch(:success_message, I18n.t('dashboard.support_ticket.rt.creation_success', ticket_id: ticket_id))
  end

end
