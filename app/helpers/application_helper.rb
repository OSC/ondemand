module ApplicationHelper

  def get_username
    ENV['USER']
  end

  def get_usergroup
    Etc.getgrgid(Etc.getpwuid.gid).name
  end

  def get_remoteuser
    ENV['REMOTE_USER']
  end
end