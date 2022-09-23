# frozen_string_literal: true

# Generic Router class (as opposed to SysRouter that is specific to system apps)
# is a utility class to query for applications.
class Router
  # Return a Router [SysRouter, UsrRouter or DevRouter] based off
  # of the input token. Returns nil if nothing is parsed correctly.
  #
  # return [SysRouter, UsrRouter or DevRouter]
  def self.router_from_token(token)
    type, *app = token.split('/')
    case type
    when 'dev'
      name, = app
      DevRouter.new(name)
    when 'usr'
      owner, name, = app
      UsrRouter.new(name, owner)
    when 'sys'
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

    @pinned_apps[tokens_key] = tokens.to_a.each_with_object([]) do |token, pinned_apps|
      pinned_apps.concat pinned_apps_from_token(token, all_apps)
    end.uniq do |app|
      app.token.to_s
    end.reject do |app|
      # subapps are featured apps and this is the easiest way to tell if it's valid.
      # instead of say app.send(:sub_app_list).first.valid?
      app.links.empty?
    end
  end

  def self.pinned_apps_from_token(token, all_apps)
    matcher = TokenMatcher.new(token)

    all_apps.each_with_object([]) do |app, apps|
      if app.has_sub_apps?
        apps.concat(featured_apps_from_sub_app(app, matcher))
      elsif matcher.matches_app?(app)
        apps.append(app)
      end
    end
  end

  def self.featured_apps_from_sub_app(app, matcher)
    app.sub_app_list.each_with_object([]) do |sub_app, apps|
      apps.append(AppRecategorizer.new(app, token: sub_app.token)) if matcher.matches_app?(sub_app)
    end
  end
end
