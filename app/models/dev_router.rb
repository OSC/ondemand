class DevRouter
  attr_reader :owner

  # returns list of apps with this router injected into it
  def self.apps
    # TODO:
  end

  def base_path
    "#{Dir.home(owner)}/#{ENV['OOD_PORTAL']}/dev"
  end

  def initialize(owner=OodSupport::Process.user.name)
    @owner = owner
  end

  def url_for(app: app_name)
    "/pun/sys/#{app}"
  end

  #FIXME: is this method required?
  def path_for(app: app_name)
    "#{base_path}/#{app}"
  end
end
