class SysRouter
  def url_for(app: app_name)
    "/pun/sys/#{app}"
  end

  def path_for(app: app_name)
    "/var/www/ood/apps/sys/#{app}"
  end
end
