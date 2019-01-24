class JobsController < ApplicationController
  include ApplicationHelper

  def index
    @jobfilter = get_filter
    @jobcluster = get_cluster

    respond_to do |format|
      format.html # index.html.erb
      format.json {
        render :json => get_jobs
      }
    end
  end

  def json
    respond_to do |format|
      format.html { # show.html.erb
        raise "html"
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
  # @param [String] cluster The id of the cluster as string
  #
  # @return [Jobstatusdata] The job data as a Jobstatusdata object
  def get_job(jobid, cluster)
    begin
      data = OODClusters[cluster].job_adapter.info(jobid)

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

  # Get a set of jobs defined by the filtering parameter.
  def get_jobs
    jobs = Array.new
    errors = Array.new

    clusters.each do |cluster|
      b = cluster.job_adapter

      begin
        if filter.user?
          result = b.info_where_owner(OodSupport::User.new.name)
        else
          result = filter.apply(b.info_all)
        end

        # Only add the running jobs to the list and assign the host to the object.
        #
        # There is also curently a bug in the system where jobs with an empty array
        # (ex. 6407991[].oak-batch.osc.edu) are not stattable, so we do a not-match
        # for those jobs and don't display them.
        result.each do |j|
          if j.status.state != :completed && j.id !~ /\[\]/
            jobs.push(Jobstatusdata.new(j, cluster))
          end
        end
      rescue => e
        msg = "#{cluster.metadata.title || cluster.id.to_s.titleize}: #{e.message}"
        logger.error "#{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
        errors << msg
      end
    end

    # Sort jobs by username
    jobs.sort_by! do |user|
      user.username == OodSupport::User.new.name ? 0 : 1
    end

    { data: jobs, errors: errors }
  end

  def filter
    filter_id = get_filter
    Filter.list.find(Filter.all_filter) { |f| f.filter_id == filter_id  }
  end

  def clusters
    cluster_id = get_cluster
    if cluster_id == 'all'
      OODClusters
    else
      OODClusters.select { |c| c == cluster_id}
    end
  end
end
