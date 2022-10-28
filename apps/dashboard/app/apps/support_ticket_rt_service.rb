# frozen_string_literal: true

# Service class responsible to create a support ticket and delivery it via request tracker API
#
# It implements the support ticket interface as defined in the SupportTicketController
class SupportTicketRtService
  # Creates a support ticket model with default data.
  # Will load an interactive session if a session_id provided in the request parameters.
  # Accepts a queue parameter to override the default. Useful for testing.
  #
  # @param [Hash] request_params Request data sent to the controller
  #
  # @return [SupportTicket] support_ticket model
  def default_support_ticket(params)
    defaults = {}.tap do |defaults|
      defaults[:session_id] = params[:session_id]
      defaults[:queue] = params[:queue]
    end

    support_ticket = SupportTicket.new(defaults)
    set_session(support_ticket)
  end

  # Uses SupportTicket model to create and validate the request data.
  # The model needs to be validated before returning
  #
  # @param [Hash] request_data Request data posted to the controller
  #
  # @return [SupportTicket] support_ticket model
  def validate_support_ticket(request_data = {})
    support_ticket = SupportTicket.new(request_data)
    set_session(support_ticket)
    support_ticket.tap(&:validate)
  end

  # Creates a support ticket in the request tracker system configured
  #
  # @param [SupportTicket] support_ticket support ticket created in validate_support_ticket
  #
  # @return [String] success message
  def deliver_support_ticket(support_ticket)
    service_config = ::Configuration.support_ticket_config.fetch(:rt_api, {})
    rts = RequestTrackerService.new
    ticket_id = rts.create_ticket(support_ticket)
    service_config.fetch(:success_message, I18n.t('dashboard.support_ticket.rt.creation_success', ticket_id: ticket_id))
  end

  private

  def set_session(support_ticket)
    if !support_ticket.session_id.blank? && BatchConnect::Session.exist?(support_ticket.session_id)
      support_ticket.session = BatchConnect::Session.find(support_ticket.session_id)
    end
    support_ticket
  end
end
