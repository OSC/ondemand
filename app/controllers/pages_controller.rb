class PagesController < ApplicationController

  def index
    c = PBS::Conn.batch 'oakley'
    #q = PBS::Query.new conn: c, type: :node
    q = PBS::Query.new conn: c, type: :job

    # Get all
    @activejobs = q.find

    # Get user
    # q.where.user('username').find
  end
end
