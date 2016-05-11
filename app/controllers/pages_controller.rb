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
      if Servers.has_key?(params[:host])
        render :json => get_job(params[:pbsid], params[:host])
      end
    end
  end

  def delete_job

    # Only delete if the pbsid and host params are present and host is configured in servers.
    # PBS will prevent a user from deleting a job that is not their own and throw an error.
    if (params[:pbsid] && Servers.has_key?(params[:host]))
      job_id = params[:pbsid].to_s.gsub(/_/, '.')

      begin
        c = PBS::Conn.batch params[:host]
        j = PBS::Job.new(conn: c, id: job_id)
        j.delete

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
  def get_job(pbsid, host)
    begin
      c = PBS::Conn.batch host
      q = PBS::Query.new conn: c, type: :job

      Jobstatusdata.new(q.find(id: pbsid).first, host, true)

    rescue
      "[{\"name\":\"#{pbsid}\",\"error\":\"Job data expired or invalid.\"}]"
    end
  end

  # Get a set of jobs defined by the filtering cookie.
  def get_jobs
    jobs = Array.new
    Servers.each do |key, value|
      c = PBS::Conn.batch key
      q = PBS::Query.new conn: c, type: :job

      # Checks the cookies and gets the appropriate job set.
      if cookies[:jobfilter] == 'all'
        # Get all jobs
        result = q.find.each
      elsif cookies[:jobfilter] == 'group'
        # Get all group jobs
        result = q.where.is(PBS::ATTR[:egroup] => get_usergroup).find
      else
        # Get all user jobs
        result = q.where.user(get_username).find
      end

      # Only add the running jobs to the list and assign the host to the object.
      #
      # There is also curently a bug in the system where jobs with an empty array
      # (ex. 6407991[].oak-batch.osc.edu) are not stattable, so we do a not-match
      # for those jobs and don't display them.
      result.each do |job|
        if job[:attribs][:job_state] != 'C' && job[:name] !~ /\[\]/
          jobs.push(Jobstatusdata.new(job, key))
        end
      end
    end

    # Sort jobs by username, then group
    jobs.sort_by! do |user|
      user.username == get_username ? 0 : user.group == get_usergroup ? 1 : 2
    end
  end
end
