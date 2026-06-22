# frozen_string_literal: true

# Generates the support ticket payload and sends it to a request tracker system using the API
#
class RequestTrackerService
  attr_reader :rt_config, :queues, :priority

  def initialize(request_tracker_config)
    @rt_config = request_tracker_config
    @queues = rt_config[:queues]
    @priority = rt_config[:priority]

    if !queues || queues.empty? || !priority
      raise ArgumentError, 'queues and priority are required options for RequestTrackerService'
    end
  end

  def create_ticket(support_ticket_request, session, job)
    ticket_template_context = {
      session:     session,
      job:         job,
      description: support_ticket_request.description,
      username:    support_ticket_request.username
    }

    template_path = File.join('support_ticket/rt', rt_config.fetch(:template, 'rt_ticket_content'))
    ticket_text = ApplicationController.render(
      template: template_path,
      formats: [:text], # so Rails prefers *.text.* variants
      locals: {
        context: ticket_template_context,
        helpers: TemplateHelpers.new
      }
    )

    payload = create_payload(support_ticket_request, ticket_text)
    rt_client = RequestTrackerClient.new(rt_config)
    rt_client.create(payload)
  end

  private

  def create_payload(support_ticket_request, ticket_text)
    # default to first configured queue
    queue = queues[0]
    if support_ticket_request.queue && support_ticket_request.queue != ''
      if queues.include?(support_ticket_request.queue)
        queue = support_ticket_request.queue
      else
        raise ArgumentError, 'invalid queue selection'
      end
    end

    payload = {
      Queue:     queue,
      Requestor: support_ticket_request.email,
      Cc:        support_ticket_request.cc,
      Priority:  priority,
      Subject:   support_ticket_request.subject,
      Text:      ticket_text
    }
    payload[:Attachments] = support_ticket_request.attachments if support_ticket_request.attachments
    payload
  end

  class TemplateHelpers
    include SupportTicketHelper
  end
end
