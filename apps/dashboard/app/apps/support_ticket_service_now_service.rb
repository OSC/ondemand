# frozen_string_literal: true

# Service class responsible to create a support ticket and delivery it via ServiceNow API
#
# It implements the support ticket interface as defined in the SupportTicketController
class SupportTicketServiceNowService

  attr_reader :support_ticket_config

  # Constructor
  #
  # @param [Hash] support_ticket_config Support ticket configuration
  def initialize(support_ticket_config)
    @support_ticket_config = support_ticket_config
  end

  # Creates a support ticket model with default data.
  # Will load an interactive session if a session_id provided in the request parameters.
  #
  # @param [Hash] request_params Request data sent to the controller
  #
  # @return [SupportTicket] support_ticket model
  def default_support_ticket(request_params)
    support_ticket = SupportTicket.from_config(support_ticket_config)
    support_ticket.username = CurrentUser.name
    support_ticket.session_id = request_params[:session_id]
    set_session(support_ticket)
  end

  # Uses SupportTicket model to create and validate the request data.
  # The model needs to be validated before returning
  #
  # @param [Hash] request_data Request data posted to the controller
  #
  # @return [SupportTicket] support_ticket model
  def validate_support_ticket(request_data = {})
    support_ticket = SupportTicket.from_config(support_ticket_config)
    support_ticket.attributes = request_data
    set_session(support_ticket)
    support_ticket.tap(&:validate)
  end

  # Creates a support ticket in the ServiceNow system configured
  #
  # @param [SupportTicket] support_ticket support ticket created in validate_support_ticket
  #
  # @return [String] success message
  def deliver_support_ticket(support_ticket)
    service_config = support_ticket_config.fetch(:servicenow_api, {})
    session = get_session(support_ticket)
    description = create_description_text(service_config, support_ticket, session)
    payload = {
      caller_id:         support_ticket.username,
      short_description: support_ticket.subject,
      description:       description,
    }

    mapping_fields = service_config.fetch(:map, {})
    mapping_fields.each do |snow_field, form_field|
      # Map field names from the form into field names from ServiceNow
      payload[snow_field] = support_ticket.send(form_field)
    end

    custom_payload = service_config.fetch(:payload, {})
    custom_payload.each do |key, value|
      # Use the values from the custom payload if available.
      # Default to the values from the form.
      payload[key] = value.nil? ? support_ticket.send(key) : value
    end

    snow_client = ServiceNowClient.new(service_config)
    result = snow_client.create(payload, support_ticket.attachments)
    Rails.logger.info "Support Ticket created in ServiceNow: #{result.number} - Attachments[#{result.attachments}] success=#{result.attachments_success}"
    message_key = result.attachments_success ? 'creation_success' : 'attachments_failure'
    service_config.fetch(:success_message, I18n.t("dashboard.support_ticket.servicenow.#{message_key}", number: result.number))
  end

  private

  def create_description_text(service_config, support_ticket_request, session)
    ticket_template_context = {
      session:        session,
      support_ticket: support_ticket_request,
    }

    template = service_config.fetch(:template, 'servicenow_content.text.erb')
    ticket_content_template = ERB.new(File.read(Rails.root.join('app/views/support_ticket/servicenow').join(template)))
    ticket_content_template.result_with_hash({ context: ticket_template_context, helpers: TemplateHelpers.new })
  end

  def set_session(support_ticket)
    session = get_session(support_ticket)
    if session
      created_at = session.created_at ? Time.at(session.created_at).localtime.strftime("%Y-%m-%d %H:%M:%S %Z") : "N/A"
      support_ticket.session_description = "#{session.title}(#{session.job_id}) - #{session.status} - #{created_at}"
    end

    support_ticket
  end

  def get_session(support_ticket)
    if !support_ticket.session_id.blank? && BatchConnect::Session.exist?(support_ticket.session_id)
      BatchConnect::Session.find(support_ticket.session_id)
    end
  end

  class TemplateHelpers
    include SupportTicketHelper
  end
end
