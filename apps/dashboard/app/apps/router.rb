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
    @pinned_apps ||= {}
    tokens_key = ActiveSupport::Cache.expand_cache_key(tokens)
    return @pinned_apps[tokens_key] if @pinned_apps.key?(tokens_key)

    @pinned_apps[tokens_key] = self.feature_apps(tokens, all_apps, feature: I18n.t("dashboard.pinned_apps_category"), sub_feature: I18n.t('dashboard.pinned_apps_title'))
  end

  # Returns an array of unique apps that match at least one of the tokens provided.
  # It uses the TokenMatcher to match tokens with apps
  # Should at least return an empty array.
  #
  # @return [FeaturedApp]
  def self.feature_apps(tokens, all_apps, feature: nil, sub_feature: nil)
    tokens.to_a.each_with_object([]) do |token, pinned_apps|
      pinned_apps.concat featured_apps_from_token(token, all_apps, feature, sub_feature)
    end.uniq do |app|
      app.token.to_s
    end.reject do |app|
      # subapps are featured apps and this is the easiest way to tell if it's valid.
      # instead of say app.send(:sub_app_list).first.valid?
      app.links.empty?
    end
  end

  private

  def self.featured_apps_from_token(token, all_apps, feature, sub_feature)
    matcher = TokenMatcher.new(token)

    all_apps.each_with_object([]) do |app, apps|
      if app.has_sub_apps?
        apps.concat(featured_apps_from_sub_app(app, matcher, feature, sub_feature))
      else
        apps.append(FeaturedApp.from_app(app, feature: feature, sub_feature: sub_feature)) if matcher.matches_app?(app)
      end
    end
  end

  def self.featured_apps_from_sub_app(app, matcher, feature, sub_feature)
    app.sub_app_list.each_with_object([]) do |sub_app, apps|
      apps.append(FeaturedApp.from_app(app, token: sub_app.token, feature: feature, sub_feature: sub_feature)) if matcher.matches_app?(sub_app)
    end
  end
end
