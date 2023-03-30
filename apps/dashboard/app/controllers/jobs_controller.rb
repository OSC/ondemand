# frozen_string_literal: true

# The controller for jobs API /dashboard/jobs
class JobsController < ApplicationController
  def info
    respond_to do |format|
      format.json do
        cluster = OodAppkit.clusters[info_params[:cluster].to_sym]
        render :json => {}, :status => 404 if cluster.nil?

        job_info = cluster.job_adapter.info(info_params[:id].to_s)
        render :json => info_to_hash(job_info)
      end
    end
  end

  def info_to_hash(info)
    {
      state: info.status.state
    }
  end

  def info_params
    params.permit(:cluster, :id)
  end
end
