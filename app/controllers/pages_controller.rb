class PagesController < ApplicationController
  include ApplicationHelper

  def index
  end

  # Used to send the data to the Datatable.
  def json
    if params[:pbsid].nil?
      render :json => get_jobs
    else
      render :json => get_job(params[:pbsid])
    end
  end

  def delete_job
    if params[:pbsid] && (params[:host])
      job_id = params[:pbsid].gsub!(/_/, '.')

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

  def get_job(pbsid, host)
    begin

      # TODO Get this out of here and set with params
      if pbsid.include? 'oak-batch'
        host = 'oakley'
      else
        host = 'ruby'
      end

      c = PBS::Conn.batch host
      q = PBS::Query.new conn: c, type: :job

      Jobstatusdata.new(q.find(id: pbsid).first, host, true)

    rescue
      "[{\"name\":\"#{pbsid}\",\"error\":\"Job data expired or invalid.\"}]"
    end
  end

  def get_jobs
    jobs = Array.new
    Servers.each do |key, value|
      c = PBS::Conn.batch key
      q = PBS::Query.new conn: c, type: :job

      # Checks the cookies and gets the appropriate job set.
      if cookies[:jobfilter] == 'all'
        result = q.find.each
      elsif cookies[:jobfilter] == 'group'
        # Get all group jobs
        result = q.where.is(PBS::ATTR[:egroup] => get_usergroup).find
      else
        result = q.where.user(get_username).find
      end
      result.each do |job|
        # Only add the running jobs to the list and assign the host to the object.
        if job[:attribs][:job_state] != 'C'
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