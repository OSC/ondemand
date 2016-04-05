class AppRouter < AweSim::Router
  # given app string "dashboard"
  # return url for app to access
  # FIXME: we should derive this from the nginx_stage gem
  def url_for_dev_app(app)
    "/pun/dev/#{app}"
  end

  # given app string "dashboard"
  # and owner "efranz" return the url
  def url_for_shared_app(app)
    "/pun/shared/#{user}/#{app}"
  end

  def shared_apps_path
    "#{Dir.home(user)}/ood_shared"
  end

  def dev_apps_path
    "#{Dir.home(user)}/ood_dev"
  end

  def setup_access_to_apps_of(user: nil)
    # nothing to do here!
  end
end
