# frozen_string_literal: true

# The controller for jobs API /dashboard/jobs
class JobsController < ApplicationController
  def pm_job_details
    cluster_str = info_params[:cluster].to_s
    cluster = OodAppkit.clusters[cluster_str.to_sym]
    render(:status => 404) if cluster.nil?

    job_info = cluster.job_adapter.info(info_params[:id].to_s)
    hpc_job = HpcJob.from_core_info(info: job_info, cluster: cluster_str)
    render(partial: 'pm_job_panel', locals: { job: hpc_job })
  end

  def info_params
    params.permit(:cluster, :id)
  end
end
