class PagesController < ApplicationController

  def index
    c = PBS::Conn.batch 'oakley'
    #q = PBS::Query.new conn: c, type: :node
    q = PBS::Query.new conn: c, type: :job

    # Get all Oakley
    oakleyjobs = q.find

    c = PBS::Conn.batch 'ruby'
    #q = PBS::Query.new conn: c, type: :node
    q = PBS::Query.new conn: c, type: :job

    # Get all Ruby
    rubyjobs = q.find

    @activejobs = oakleyjobs.concat rubyjobs
    # Get user
    # q.where.user('username').find
  end
end
