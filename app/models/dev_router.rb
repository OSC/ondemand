class DevRouter
  attr_reader :owner

  def initialize(owner=OodSupport::Process.user.name)
    @owner = owner
  end

  def url_for(app: app_name)
    "/pun/sys/#{app}"
  end

  def path_for(app: app_name)
    Dir.home(owner)
    "/var/www/ood/apps/sys/#{app}"
  end
end
