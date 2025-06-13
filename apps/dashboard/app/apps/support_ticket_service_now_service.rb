# frozen_string_literal: true

# Service class responsible to create a support ticket and delivery it via ServiceNow API
#
# It implements the support ticket interface as defined in the SupportTicketController
class SupportTicketServiceNowService
  include SupportTicketService

  attr_reader :support_ticket_config

  # Constructor
  #
  # @param [Hash] support_ticket_config Support ticket configuration
  def initialize(support_ticket_config)
    @support_ticket_config = support_ticket_config
  end

  # Creates a support ticket in the ServiceNow system configured
  #
  # @param [SupportTicket] support_ticket support ticket created in validate_support_ticket
  #
  # @return [String] success message
  def deliver_support_ticket(support_ticket)
    service_config = support_ticket_config.fetch(:servicenow_api, {})
    session = get_session(support_ticket)
    job = get_job(support_ticket)
    description = create_description_text(service_config, support_ticket, session, job)
    payload = {
      caller_id:         support_ticket.email,
      watch_list:        support_ticket.cc,
      short_description: support_ticket.subject,
      description:       description
    }

    mapping_fields = service_config.fetch(:map, {}).to_h
    mapping_fields.each do |snow_field, form_field|
      # Map field names from the form into field names from ServiceNow
      # arrays are supported for form_field names and the values will be joined with commas.
      value = Array.wrap(form_field).map { |name| support_ticket.send(name).to_s }.reject(&:blank?).join(',')
      payload[snow_field] = value
    end

    custom_payload = service_config.fetch(:payload, {})
    custom_payload.each do |key, value|
      # Use the values from the custom payload if available.
      # Default to the values from the form when nil provided.
      payload[key] = value.nil? ? support_ticket.send(key) : value
    end

    snow_client = ServiceNowClient.new(service_config)
    result = snow_client.create(payload, support_ticket.attachments)
    Rails.logger.info "Support Ticket created in ServiceNow: #{result.number} - Attachments[#{result.attachments}] success=#{result.attachments_success}"
    message_key = result.attachments_success ? 'creation_success' : 'attachments_failure'
    service_config.fetch(:success_message,
                         I18n.t("dashboard.support_ticket.servicenow.#{message_key}", number: result.number))
  end

  private

  def create_description_text(service_config, support_ticket_request, session, job)
    ticket_template_context = {
      session:        session,
      job:            job,
      support_ticket: support_ticket_request
    }

    template = service_config.fetch(:template, 'servicenow_content.text.erb')
    ticket_content_template = ERB.new(File.read(Rails.root.join('app/views/support_ticket/servicenow').join(template)))
    ticket_content_template.result_with_hash({ context: ticket_template_context, helpers: TemplateHelpers.new })
  end

  class TemplateHelpers
    include SupportTicketHelper
  end
end
