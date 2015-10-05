class PagesController < ApplicationController
  include ApplicationHelper

  def index

    # Get all Oakley jobs
    c = PBS::Conn.batch 'oakley'
    q = PBS::Query.new conn: c, type: :job
    oakleyjobs = q.find

    # Get all Ruby jobs
    c = PBS::Conn.batch 'ruby'
    q = PBS::Query.new conn: c, type: :job
    rubyjobs = q.find

    # Join the arrays
    @activejobs = oakleyjobs.concat rubyjobs

    # Sort the user's jobs to the top
    @activejobs.sort_by! { |user| [ username(user[:attribs][:Job_Owner]) == ENV['USER'] ? 0 : 1 ] }

    # Get user example:
    # q.where.user('username').find
  end
end
