# frozen_string_literal: true

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
  # GET /support?job_id=<job_id>&cluster=<cluster>
  # session_id [UUID] optional session to add data to the support ticket
  # job_id [Integer] cluster [String] optional job id and cluster to add data to the support ticket
  def new
    support_service = create_service_class
    @support_ticket = support_service.default_support_ticket(params)

    render get_ui_template

  rescue StandardError => e
    logger.error "Could not render support ticket page. Error=#{e}"
    redirect_to root_url, :flash => { :alert => t('dashboard.support_ticket.generic_error', error: e) }
  end

  # POST /support
  def create
    support_service = create_service_class
    @support_ticket = support_service.validate_support_ticket(read_support_ticket_from_request)

    if !@support_ticket.errors.empty?
      flash.now[:alert] = t('dashboard.support_ticket.validation_error')
      render get_ui_template
      return
    end

    support_ticket_response = support_service.deliver_support_ticket(@support_ticket)
    redirect_to root_url, :flash => { :notice => support_ticket_response }
  rescue StandardError => e
    logger.error "Could not create support ticket. support_service=#{support_service} error=#{e}"
    flash.now[:alert] = t('dashboard.support_ticket.generic_error', error: e)
    render get_ui_template
  end

  private

  def create_service_class
    @user_configuration.support_ticket_service
  end

  def get_ui_template
    @user_configuration.support_ticket.fetch(:ui_template, 'email_service_template')
  end

  def read_support_ticket_from_request
    params.require(:support_ticket).permit!
  end
end
