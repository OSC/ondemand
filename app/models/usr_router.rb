class UsrRouter
  attr_reader :owner

  # returns list of apps with this router injected into it
  # if owner is null, returns all apps of all owners this process has access to
  # otherwise returns list of apps from current owner
  # FIXME: expensive method!
  def self.apps(owner: null)
    # TODO:
  end

  def self.for(owner)
    owner == "sys" ? ::SysRouter.new : ::UsrRouter.new(owner)
  end

  #FIXME: implement UsrRouter, DevRouter to replace this class
  #FIXME: these should ultimately go into OodAppkit
  def initialize(owner)
    @owner = owner
  end

  def base_path
    "/var/www/ood/apps/usr/#{owner}/gateway"
  end

  def url_for(app: app_name)
    "/pun/usr/#{owner}/#{app}"
  end

  def path_for(app: app_name)
    "#{base_path}/#{app}"
  end
end
