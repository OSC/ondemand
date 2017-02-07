module ApplicationHelper

  def get_username
    OodSupport::User.new.name
  end

  def get_usergroup
    OodSupport::User.new.group.name
  end

  def get_remoteuser
    ENV['REMOTE_USER']
  end
end
