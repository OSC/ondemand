class Router

  # Return a Router [SysRouter, UsrRouter or DevRouter] based off
  # of the input token. Returns nil if nothing is parsed correctly.
  #
  # return [SysRouter, UsrRouter or DevRouter]
  def self.router_from_token(token)
    type, *app = token.split("/")
    case type
    when "dev"
      name, = app
      DevRouter.new(name)
    when "usr"
      owner, name, = app
      UsrRouter.new(name, owner)
    when "sys"
      name, = app
      SysRouter.new(name)
    end
  end

  # All the configured "Pinned Apps". Returns an array of unique and already rejected apps
  # that may be problematic (inaccessible or idden and so on). Should at least return an
  # an empty array.
  #
  # @return [FeaturedApp]
  def self.pinned_apps(tokens, all_apps)
    @pinned_apps ||= tokens.to_a.each_with_object([]) do |token, pinned_apps|
      pinned_apps.concat pinned_apps_from_token(token, all_apps)
    end.uniq do |app|
      app.token.to_s
    end.reject do |app|
      app.invalid_batch_connect_app?
    end
  end

  private

  def self.pinned_apps_from_token(token, all_apps)
    all_apps.select do |app|
      glob_match = File.fnmatch(token, app.token, File::FNM_EXTGLOB)
      sub_app_match = token.start_with?(app.token) # find bc/desktop/pitzer from sys/bc_desktop

      glob_match || sub_app_match
    end.each_with_object([]) do |app, apps|
      if app.has_sub_apps?
        apps.concat(featured_apps_from_sub_app(app, token))
      else
        apps.append(FeaturedApp.from_ood_app(app))
      end
    end
  end

  def self.featured_apps_from_sub_app(app, token)
    app.sub_app_list.each_with_object([]) do |sub_app, apps|
      glob_match = File.fnmatch(token, sub_app.token, File::FNM_EXTGLOB)
      apps.append(FeaturedApp.from_ood_app(app, token: sub_app.token)) if glob_match
    end
  end
end
