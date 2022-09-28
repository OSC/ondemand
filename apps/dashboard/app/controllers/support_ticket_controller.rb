# The controller to create support tickets
#
# It uses a support ticket service class that must implement the interface:
#  - default_support_ticket(request_params):
#  Creates a support ticket object with default data.
#  - validate_support_ticket(request_data):
#  It creates and validates a support ticket object based on the request data
#  - deliver_support_ticket(support_ticket):
#  Sends the support ticket to the third party system.
class SupportTicketController < ApplicationController

  # GET /support?session_id=<session_UUID>
  # session_id [UUID] optional session to add data to the support ticket
  def new
    support_service = create_service_class
    @support_ticket = support_service.default_support_ticket(params)

    render get_ui_template
  end

  # POST /support
  def create
    read_support_ticket_from_request

    support_service = create_service_class
    @support_ticket = support_service.validate_support_ticket(read_support_ticket_from_request)

    if @support_ticket.invalid? || !@support_ticket.errors.empty?
      flash.now[:alert] = t('dashboard.support_ticket.validation_error')
      render get_ui_template
      return
    end

    support_ticket_response = support_service.deliver_support_ticket(@support_ticket)
    redirect_to root_url, :flash => { :notice => support_ticket_response }

    rescue => error
      logger.error "Could not create support ticket. support_service=#{support_service} error=#{error}"
      flash.now[:alert] = t('dashboard.support_ticket.generic_error', error: error)
      render get_ui_template
  end

  private

  # Load support ticket service class based on the configuration
  def create_service_class
    # Supported delivery mechanism
    if ::Configuration.support_ticket_config[:email]
      return SupportTicketEmailService.new
    end
    raise StandardError, "No support ticket service class configured"
  end

  def get_ui_template
    ::Configuration.support_ticket_config.fetch(:ui_template, "email_service_template")
  end

  def read_support_ticket_from_request
    params.require(:support_ticket).permit!
  end
end
