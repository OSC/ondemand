class PagesController < ApplicationController
  include ApplicationHelper

  def index
  end

  # Used to send the data to the Datatable.
  def json
    if params[:pbsid].nil?
      render :json => get_data
    else
      render :json => get_job(params[:pbsid])
    end
  end

  def delete_job
    if params[:pbsid]
      job_id = params[:pbsid].gsub!(/_/, '.')
      # TODO Get this out of here and set with params
      if job_id.include? 'oak-batch'
        host = 'oakley'
      else
        host = 'ruby'
      end

      begin
        c = PBS::Conn.batch host
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

  # Converts the PBS data to Jobstatusdata objects so we
  # don't send as much data down the pipe to the user.
  def get_data
    data_array = Array.new
    get_jobs.each do |j|
      # don't include completed jobs in the payload.
      if j[:attribs][:job_state] != 'C'
        data_array.push(Jobstatusdata.new(j))
      end
    end
    data_array
  end

  def get_job(pbsid)
    begin

      # TODO Get this out of here and set with params
      if pbsid.include? 'oak-batch'
        host = 'oakley'
      else
        host = 'ruby'
      end

      c = PBS::Conn.batch host
      q = PBS::Query.new conn: c, type: :job
      #q.find(id: pbsid)

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
        jobs.push(q.find)
      elsif cookies[:jobfilter] == 'group'
        # Get all group jobs
        jobs.push(q.where.is(PBS::ATTR[:egroup] => get_usergroup).find)
      else
        jobs.push(q.where.user(get_username).find)
      end

    end
    jobs = jobs.flatten

    jobs.sort_by! do |user|
      user[:attribs][:euser] == get_username ? 0 : user[:attribs][:egroup] == get_usergroup ? 1 : 2
    end
  end
end