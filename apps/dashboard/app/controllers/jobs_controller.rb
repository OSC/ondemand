# The controller for activejobs pages /dashboard/activejobs
class JobsController < ApplicationController
  def info
    respond_to do |format|
      format.json do
        cluster = OodAppkit.clusters[info_params[:cluster].to_sym]
        render_404 if cluster.nil?

        job_info = cluster.job_adapter.info(info_params[:id].to_s)
        info = {
          state: job_info.status.state
        }
        render :json => info
      end
    end
  end

  def render_404
    render :json => {}, :status => 404
  end

  def info_params
    params.permit(:cluster, :id)
  end
end
