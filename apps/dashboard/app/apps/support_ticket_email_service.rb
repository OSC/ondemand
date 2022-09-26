class SupportTicketEmailService

  def default_support_ticket(params)
    email_service_config = ::Configuration.support_ticket_config.fetch(:email, {})
    defaults = email_service_config.fetch(:defaults, {})
    defaults[:session_id] = params[:session_id]
    support_ticket = SupportTicket.new(defaults)
    set_session(support_ticket)
  end

  def validate_support_ticket(request_data = {})
    support_ticket = SupportTicket.new(request_data)
    set_session(support_ticket)
  end

  def deliver_support_ticket(support_ticket)
    email_service_config = ::Configuration.support_ticket_config.fetch(:email, {})

    context = OpenStruct.new({
      support_ticket: support_ticket,
    })

    SupportTicketMailer.with(context: context).support_email.deliver_now
    email_service_config.fetch(:success_message, I18n.t('dashboard.support_ticket.creation_success', to: email_service_config.fetch(:to)))
  end

  private

  def set_session(support_ticket)
    if !support_ticket.session_id.blank? && BatchConnect::Session.exist?(support_ticket.session_id)
      support_ticket.session = BatchConnect::Session.find(support_ticket.session_id)
    end
    support_ticket
  end
end