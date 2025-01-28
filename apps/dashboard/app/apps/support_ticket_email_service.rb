# frozen_string_literal: true

# Service class responsible to create a support ticket and delivery it via email
#
# It implements the support ticket interface as defined in the SupportTicketController
class SupportTicketEmailService
  include SupportTicketService

  attr_reader :support_ticket_config

  # Constructor
  #
  # @param [Hash] support_ticket_config Support ticket configuration
  def initialize(support_ticket_config)
    @support_ticket_config = support_ticket_config
  end

  # Sends an email with the support ticket data
  #
  # @param [SupportTicket] support_ticket support ticket created in validate_support_ticket
  #
  # @return [String] success message
  def deliver_support_ticket(support_ticket)
    email_service_config = support_ticket_config.fetch(:email, {})
    session = get_session(support_ticket)
    job = get_job(support_ticket)
    context = OpenStruct.new({
                               support_ticket: support_ticket,
                               session:        session,
                               job:            job
                             })

    SupportTicketMailer.support_email(support_ticket_config, context).deliver_now
    email_service_config.fetch(:success_message,
                               I18n.t('dashboard.support_ticket.creation_success', to: email_service_config.fetch(:to)))
  end

end
