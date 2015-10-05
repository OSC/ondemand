module ApplicationHelper

  def username(attribs_Job_Owner)
    uname = attribs_Job_Owner.split('@')[0]
  end
end
