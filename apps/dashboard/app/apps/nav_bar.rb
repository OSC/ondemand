class NavBar

  attr_reader :nav_items

  def self.from_config(nav_bar)
    nav_items = nav_bar.map do |nav_item|
      NavBar.parse_nav_item(nav_item)
    end

    NavBar.new(nav_items: nav_items)
  end

  def initialize(nav_items: [])
    @nav_items = nav_items
  end

  def empty?
    nav_items.size == 0
  end

  def to_s
    "nav_items: #{nav_items}"
  end

  private

  def self.parse_nav_item(nav_item)
    type = nav_item.fetch(:type, nil) || NavBar.infer_type(nav_item)
    NavItem.new(type.to_sym, nav_item)
  end

  def self.infer_type(nav_item)
    links = nav_item.fetch(:links, nil)
    return :nav_menu if links

    url = nav_item.fetch(:url, nil)
    return :nav_link if url

    profile = nav_item.fetch(:profile, nil)
    return :nav_link if profile

    app = nav_item.fetch(:app, nil)
    return :nav_app if app

    tokens = nav_item.fetch(:tokens, nil)
    return :nav_app if tokens

    template = nav_item.fetch(:template, nil)
    return :nav_template if template

    #default type is :nav_divider
    return :nav_divider
  end

  class NavItem
    attr_reader :type, :items, :links, :title, :url, :icon, :new_tab, :template, :data

    def initialize(type, config)
      config = config.to_h.compact.symbolize_keys

      @type      = type
      @items     = config.fetch(:links, []).map{|link_item| NavBar.parse_nav_item(link_item)}

      @title     = config.fetch(:title, nil)
      @url       = config.fetch(:url, nil)
      @icon      = URI(config.fetch(:icon, "fas://cog").to_s)
      @new_tab   = !!config.fetch(:new_tab, true)

      @app       = config.fetch(:app, nil)
      @tokens    = config.fetch(:tokens, nil)
      @template  =  File.join("layouts/nav", config.fetch(:template, default_template))

      @profile   = config.fetch(:profile, nil)
      set_profile_attributes if @profile

      set_app_links if @app
      set_matched_token_links if @tokens
    end

    def items?
      items.size > 0
    end

    private

    def default_template
      File.join("custom", type.to_s)
    end

    def set_app_links
      @links = []
      app_router = Router.router_from_token(@app)
      return if app_router.nil?

      ood_app = OodApp.new(app_router)
      @links = ood_app.manifest.valid? ? ood_app.links : []
    end

    def set_matched_token_links
      matched_apps = Router.feature_apps(@tokens, SysRouter.apps)
      @links = matched_apps.each_with_object([]) do |app, links|
        links.concat(app.respond_to?(:links) ? app.links : [app.link])
      end
    end

    def set_profile_attributes
      @title = @profile unless @title
      @url = Rails.application.routes.url_helpers.settings_path("settings[profile]" => @profile)
      @data = { method: "post" }
      @new_tab = false
    end

  end

end