class PagesController < ApplicationController
  include ApplicationHelper

  def index

    o = PBS::Conn.batch 'oakley'
    oq = PBS::Query.new conn: o, type: :job

    r = PBS::Conn.batch 'ruby'
    rq = PBS::Query.new conn: r, type: :job

    if cookies[:getalljobs]
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
