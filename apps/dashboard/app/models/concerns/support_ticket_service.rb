#
# Common methods to all Support Ticket backend services
#
module SupportTicketService

  # Creates a support ticket model with default data.
  # will load an interactive session if a session_id provided in the request parameters.
  #
  # @param [Hash] request_params Request data sent to the controller
  #
  # @return [SupportTicket] support_ticket model
  def default_support_ticket(request_params)
    support_ticket = SupportTicket.from_config(support_ticket_config)
    support_ticket.username = CurrentUser.name
    support_ticket.session_id = request_params[:session_id]
    support_ticket.job_id = request_params[:job_id]
    support_ticket.cluster = request_params[:cluster]
    support_ticket.queue = request_params[:queue]
    set_session(support_ticket)
    set_job(support_ticket)
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
    set_job(support_ticket)
    support_ticket.tap(&:validate)
  end

  private

  def set_session(support_ticket)
    session = get_session(support_ticket)
    if session
      created_at = session.created_at ? Time.at(session.created_at).localtime.strftime('%Y-%m-%d %H:%M:%S %Z') : 'N/A'
      support_ticket.session_description = "#{session.title}(#{session.job_id}) - #{session.status} - #{created_at}"
    end

    support_ticket
  end

  def set_job(support_ticket)
    job = get_job(support_ticket)
    if job
      submission_time = job.submission_time ? Time.at(job.submission_time).localtime.strftime('%Y-%m-%d %H:%M:%S %Z') : 'N/A'
      support_ticket.job_description = "Job: #{job.id} - #{job.status} - #{submission_time}"
    end

    support_ticket
  end

  def get_session(support_ticket)
    if !support_ticket.session_id.blank? && BatchConnect::Session.exist?(support_ticket.session_id)
      BatchConnect::Session.find(support_ticket.session_id)
    end
  end

  def get_job(support_ticket)
    if !support_ticket.job_id.blank? && !support_ticket.cluster.blank?
      cluster = OODClusters[support_ticket.cluster.to_sym]
      cluster.job_adapter.info(support_ticket.job_id)
    end
  rescue => e
    Rails.logger.info("SupportTicket - Invalid job id: #{support_ticket.job_id} - #{e}:#{e.message}")
    nil
  end

end
