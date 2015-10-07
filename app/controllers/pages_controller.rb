class PagesController < ApplicationController
  include ApplicationHelper

  def index
  end

  # Used to send the data to the Datatable.
  def json
    render :json => get_data
  end

  private

    # Converts the PBS data to Jobstatusdata objects so we
    # don't send as much data down the pipe to the user.
    def get_data
      data_array = Array.new
      get_jobs.each do |j|
        data_array.push(Jobstatusdata.new(j))
      end
      data_array
    end

    def get_jobs
      # Set up the Oakley Connection
      oc = PBS::Conn.batch 'oakley'
      oq = PBS::Query.new conn: oc, type: :job

      # Set up the Roby Connection
      rc = PBS::Conn.batch 'ruby'
      rq = PBS::Query.new conn: rc, type: :job

      # FIXME: Remove the bang to just show user data!!! Here for testing.
      if !cookies[:getalljobs]
        # Get all Oakley jobs
        oakleyjobs = oq.find
        # Get all Ruby jobs
        rubyjobs = rq.find
      else
        # Get all user Oakley jobs
        oakleyjobs = oq.where.user(ENV['USER']).find
        # Get all user Ruby jobs
        rubyjobs = rq.where.user(ENV['USER']).find
      end

      # Join the arrays
      @activejobs = oakleyjobs.concat rubyjobs

      # Sort the user's jobs to the top
      @activejobs.sort_by! { |user| [ username(user[:attribs][:Job_Owner]) == ENV['USER'] ? 0 : 1 ] }

      # Get user example:
      # q.where.user('username').find
    end
end
