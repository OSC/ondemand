# frozen_string_literal: true

# Service class responsible to create a support ticket and delivery it via email
#
# It implements the support ticket interface as defined in the SupportTicketController
class SupportTicketEmailService
  # Creates a support ticket model with default data.
  # will load an interactive session if a session_id provided in the request parameters.
  #
  # @param [Hash] request_params Request data sent to the controller
  #
  # @return [SupportTicket] support_ticket model
  def default_support_ticket(request_params)
    email_service_config = ::Configuration.support_ticket_config.fetch(:email, {})
    defaults = email_service_config.fetch(:defaults, {})
    defaults[:session_id] = request_params[:session_id]
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
    support_ticket.tap{|ticket| ticket.validate }
  end

  # Sends and email with the support ticket data
  #
  # @param [SupportTicket] support_ticket support ticket created in validate_support_ticket
  #
  # @return [String] success message
  def deliver_support_ticket(support_ticket)
    email_service_config = ::Configuration.support_ticket_config.fetch(:email, {})

    context = OpenStruct.new({
                               support_ticket: support_ticket
                             })

    SupportTicketMailer.support_email(context).deliver_now
    email_service_config.fetch(:success_message,
                               I18n.t('dashboard.support_ticket.creation_success', to: email_service_config.fetch(:to)))
  end

  private

  def set_session(support_ticket)
    if !support_ticket.session_id.blank? && BatchConnect::Session.exist?(support_ticket.session_id)
      support_ticket.session = BatchConnect::Session.find(support_ticket.session_id)
    end
    support_ticket
  end
end
