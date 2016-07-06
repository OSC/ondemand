# essentially a "null" object
# useful for instatiating App objects
# with a router injected into it
class PathRouter
  def url_for(app: app_name)
    "#"
  end

  def path_for(app: app_name)
    app
  end
end
