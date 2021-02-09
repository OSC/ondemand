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

  def self.pinned_apps
    @pinned_apps ||= Configuration.pinned_apps.to_a.map do |token|
      router = router_from_token(token.to_s)
      next if router.nil?

      FeaturedApp.new(router, token: token)
    end.reject { |app| !app.accessible? || app.hidden? || app.backup? || app.invalid_batch_connect_app? }
  end
end
