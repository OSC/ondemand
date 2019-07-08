class JobsController < ApplicationController
  include ApplicationHelper
  include ActionController::Live

  def index
    @jobfilter = get_filter
    @jobcluster = get_cluster

    respond_to do |format|
      format.html # index.html.erb
      format.json {
        JobsJsonRequestHandler.new(
          filter_id: @jobfilter,
          cluster_id: params[:jobcluster],
          controller: self,
          params: params,
          response: response
        ).render
      }
    end
  end

  def json
    respond_to do |format|
      format.html { # show.html.erb
        raise ActionController::RoutingError.new('Not Found')
      }
      format.json {
        #Only allow the configured servers to respond
        if cluster = OODClusters[params[:cluster].to_s.to_sym]
          render '/jobs/extended_data', :locals => {:jobstatusdata => get_job(params[:pbsid], cluster) }
        else
          msg = "Request did not specify an available cluster. "
          msg += "Available clusters are: #{OODClusters.map(&:id).join(',')} "
          msg += "But specified cluster is: #{params[:cluster]}"
          render :json => { name: params[:pbsid], error: msg }
        end
      }
    end
  end

  def delete_job

    # Only delete if the pbsid and host params are present and host is configured in servers.
    # PBS will prevent a user from deleting a job that is not their own and throw an error.
    cluster = OODClusters[params[:cluster].to_sym]
    if (params[:pbsid] && cluster)
      job_id = params[:pbsid].to_s.gsub(/_/, '.')

      begin
        cluster.job_adapter.delete(job_id)

        # It takes a couple of seconds for the job to clear out
        # Using the sleep to wait before reload
        sleep(2.0)
        redirect_to root_url, :notice => "Successfully deleted " + job_id
      rescue
        redirect_to root_url, :alert => "Failed to delete " + job_id
      end
    else
      redirect_to root_url, :alert => "Failed to delete."
    end
  end

  private

  # Get the extended data for a particular job.
  #
  # @param [String] jobid The id of the job
  # @param [OodCore::Cluster] cluster The selected cluster instance from OODClusters
  #
  # @return [Jobstatusdata] The job data as a Jobstatusdata object
  def get_job(jobid, cluster)
    begin
      data = cluster.job_adapter.info(jobid)

      raise OodCore::JobAdapterError if data.native.nil?
      Jobstatusdata.new(data, cluster, true)

    rescue OodCore::JobAdapterError
      OpenStruct.new(name: jobid, error: "No job details because job has already left the queue." , status: status_label("completed") )
    rescue => e
      OpenStruct.new(name: jobid, error: "No job details available.\n" + e.backtrace.to_s, status: status_label("") )
    end
  end

  # Returns the filter id from the parameter if it is valid
  #
  # @return [String, nil] the filter id if valid
  def get_filter
    if params[:jobfilter] && Filter.list.any? { |f| f.filter_id == params[:jobfilter] }
      params[:jobfilter]
    end
  end

  # Returns the cluster id from the parameter if it is valid
  #
  # @return [String, nil] the cluster id if valid
  def get_cluster
    if params[:jobcluster] && (OODClusters[params[:jobcluster]] || params[:jobcluster] == 'all')
      params[:jobcluster]
    end
  end

end
