class PagesController < ApplicationController
  include ApplicationHelper

  def index
    if params[:jobfilter] && Filter.list.any? { |f| f.filter_id == params[:jobfilter] }
      @jobfilter = params[:jobfilter]
    end
  end

  # Used to send the data to the Datatable.
  def json
    if params[:pbsid].nil?
      render :json => get_jobs
    else
      #Only allow the configured servers to respond
      if cluster = OODClusters[params[:host].to_sym]
        render :json => get_job(params[:pbsid], cluster)
      end
    end
  end

  def delete_job

    # Only delete if the pbsid and host params are present and host is configured in servers.
    # PBS will prevent a user from deleting a job that is not their own and throw an error.
    cluster = OODClusters[params[:host].to_sym]
    if (params[:pbsid] && cluster)
      job_id = params[:pbsid].to_s.gsub(/_/, '.')

      begin
        cluster.job_adapter.delete(job_id)

        # It takes a couple of seconds for the job to clear out
        # Using the sleep to wait before reload
        sleep(2.0)
        redirect_to root_url, :alert => "Deleted " + job_id
      rescue
        redirect_to root_url, :alert => "Unable to delete " + job_id
      end
    else
      redirect_to root_url, :alert => "Not Deleted"
    end
  end

  private

  # Get the extended data for a particular job.
  def get_job(jobid, cluster)
    begin
      data = OODClusters[cluster].job_adapter.info(jobid)

      raise OodCore::JobAdapterError if data.native.nil?
      Jobstatusdata.new(data, cluster.id.to_s, true)

    rescue OodCore::JobAdapterError
      { name: jobid, error: "No job details because job has already left the queue." , status: "completed" }
    rescue => e
      { name: jobid, error: "No job details available.\n" + e.backtrace.to_s}
    end
  end

  # Get a set of jobs defined by the filtering parameter.
  def get_jobs
    jobs = Array.new
    OODClusters.each do |cluster|

      b = cluster.job_adapter

      # Checks the params and gets the appropriate job set.
      # Default to user set on first load
      param = params[:jobfilter] || Filter.default_id
      filter = Filter.list.find { |f| f.filter_id == param }
      result = filter ? filter.apply(b.info_all) : b.info_all

      # Only add the running jobs to the list and assign the host to the object.
      #
      # There is also curently a bug in the system where jobs with an empty array
      # (ex. 6407991[].oak-batch.osc.edu) are not stattable, so we do a not-match
      # for those jobs and don't display them.
      result.each do |j|
        if j.status.state != :completed && j.id !~ /\[\]/
          jobs.push(Jobstatusdata.new(j, cluster.id.to_s))
        end
      end
    end

    # Sort jobs by username
    jobs.sort_by! do |user|
      user.username == OodSupport::User.new.name ? 0 : 1
    end
  end
end
