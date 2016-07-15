class SysRouter
  # returns list of apps with this router injected into it
  def self.apps
    # TODO:
  end

  # TODO: consider memoizing this for the duration of the request
  # one way would be to instantiate a new SysRouter and then use that same
  # instance
  def app_exists?(appname)
    Pathname.new(path_for(app: appname)).directory?
  end

  def base_path
    "/var/www/ood/apps/sys"
  end

  def url_for(app: app_name)
    "/pun/sys/#{app}"
  end

  #FIXME: is this method required?
  def path_for(app: app_name)
    "#{base_path}/#{app}"
  end
end
