module WorkflowsHelper
  def xdmod_url_warning_message(workflow)
    return nil unless workflow.completed_at

    I18n.t('jobcomposer.xdmod_url_warning_message') if I18n.t('jobcomposer.xdmod_url_warning_message_seconds_after_job_completion').to_i > (Time.now - workflow.completed_at).to_i
  end
end
