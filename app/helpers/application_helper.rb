module ApplicationHelper

  def get_username
    OodSupport::User.new.name
  end

  def get_usergroup
    OodSupport::User.new.group.name
  end
end
