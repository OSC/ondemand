class PagesController < ApplicationController
  include ApplicationHelper

  def index
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
        server = cluster.resource_mgr_server
        b = PBS::Batch.new(
          host: server.host,
          lib: server.lib,
          bin: server.bin
        )
        b.delete_job(job_id)

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
  def get_job(pbsid, cluster)
    begin
      server = cluster.resource_mgr_server
      b = PBS::Batch.new(
        host: server.host,
        lib: server.lib,
        bin: server.bin
      )

      name, attribs = b.get_job(pbsid).first
      Jobstatusdata.new({name: name, attribs: attribs}, cluster.id, true)

    rescue
      "[{\"name\":\"#{pbsid}\",\"error\":\"Job data expired or invalid.\"}]"
    end
  end

  # Get a set of jobs defined by the filtering cookie.
  def get_jobs
    jobs = Array.new
    OODClusters.each do |key, value|
      server = value.resource_mgr_server
      b = PBS::Batch.new(
          host: server.host,
          lib: server.lib,
          bin: server.bin
      )

      # Checks the cookies and gets the appropriate job set.
      # Default to user set on first load
      cookie = cookies[:jobfilter] || 'user'
      filter = Filter.list.select { |f| f.cookie_id == cookie }.first
      result = filter.apply(b.get_jobs)

      # Only add the running jobs to the list and assign the host to the object.
      #
      # There is also curently a bug in the system where jobs with an empty array
      # (ex. 6407991[].oak-batch.osc.edu) are not stattable, so we do a not-match
      # for those jobs and don't display them.
      result.each do |id, attr|
        if attr[:job_state] != 'C' && id !~ /\[\]/
          jobs.push(Jobstatusdata.new({name: id, attribs: attr}, key))
        end
      end
    end

    # Sort jobs by username, then group
    jobs.sort_by! do |user|
      user.username == OodSupport::User.new.name ? 0 : 1
    end
  end
end
