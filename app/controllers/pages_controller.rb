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

      if pbsid.include? 'oak-batch'
        # Set up the Oakley Connection
        oc = PBS::Conn.batch 'oakley'
        oq = PBS::Query.new conn: oc, type: :job
        oq.find(id: pbsid)
      else # This is problematic since Ruby jobs don't have a specific extension on their pbsid.
        # Set up the Ruby Connection
        rc = PBS::Conn.batch 'ruby'
        rq = PBS::Query.new conn: rc, type: :job
        rq.find(id: pbsid)
      end

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
        jobs.push(q.where.is(PBS::ATTR[:egroup] => Etc.getgrgid(Etc.getpwuid.gid).name).find)
      else
        jobs.push(q.where.user(ENV['USER']).find)
      end

    end
    jobs = jobs.flatten

    jobs.sort_by! do |user|
      user[:attribs][:euser] == ENV['USER'] ? 0 : user[:attribs][:egroup] == Etc.getgrgid(Etc.getpwuid.gid).name ? 1 : 2
    end
  end
end