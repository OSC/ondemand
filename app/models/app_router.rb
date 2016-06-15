class AppRouter
  attr_reader :owner

  def self.for(owner)
    owner == "sys" ? ::SysRouter.new : ::AppRouter.new(owner)
  end

  #FIXME: implement UsrRouter, DevRouter to replace this class
  #FIXME: these should ultimately go into OodAppkit
  def initialize(owner)
    @owner = owner
  end

  def url_for(app: app_name)
    "/pun/usr/#{owner}/#{app}"
  end

  def path_for(app: app_name)
    "/var/www/ood/apps/usr/#{owner}/gateway/#{app}"
  end
end
