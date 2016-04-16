class SysRouter < AweSim::Router
  # given app string "dashboard"
  # return url for app to access
  # FIXME: we should derive this from the nginx_stage gem
  def url_for_dev_app(app)
    raise "sys owner has shared apps only"
  end

  # given app string "dashboard"
  # and owner "efranz" return the url
  def url_for_shared_app(app)
    "/pun/sys/#{app}"
  end

  # FIXME: to make this "relative to the dashboard deployment"
  # we could just specify the "shared apps path" as being the parent
  # directory of the Rails.root directory for the dashboard
  def shared_apps_path
    "/var/www/docroot/ood/apps/sys"
  end

  def dev_apps_path
    raise "sys owner has shared apps only"
  end

  def setup_access_to_apps_of(user: nil)
    # nothing to do here!
  end
end
