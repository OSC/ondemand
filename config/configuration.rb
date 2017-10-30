# dashboard app specific configuration
class Configuration
  class << self
    attr_writer :app_development_enabled
    attr_writer :app_sharing_enabled

    # FIXME: temporary
    attr_accessor :app_sharing_facls_enabled
    alias_method :app_sharing_facls_enabled?, :app_sharing_facls_enabled

    def app_development_enabled?
      return @app_development_enabled if defined? @app_development_enabled
      ENV['OOD_APP_DEVELOPMENT'].present? || DevRouter.base_path.exist?
    end
    alias_method :app_development_enabled, :app_development_enabled?

    def app_sharing_enabled?
      return @app_sharing_enabled if defined? @app_sharing_enabled
      @app_sharing_enabled = ENV['OOD_APP_SHARING'].present?
    end
    alias_method :app_sharing_enabled, :app_sharing_enabled?

    # The app's configuration root directory
    # @return [Pathname] path to configuration root
    def config_root
      Pathname.new(ENV["OOD_APP_CONFIG"] || "/etc/ood/config/apps/dashboard")
    end

    def custom_brand_bg_color
      return @custom_brand_bg_color if defined? @custom_brand_bg_color
      @custom_brand_bg_color = ENV.values_at('OOD_BRAND_BG_COLOR', 'BOOTSTRAP_NAVBAR_DEFAULT_BG', 'BOOTSTRAP_NAVBAR_INVERSE_BG').compact.first
    end

    # what is the correct name for this option?
    def custom_brand_link_active_bg_color
      return @custom_brand_link_active_bg_color if defined? @custom_brand_link_active_bg_color
      @custom_brand_link_active_bg_color = ENV.values_at('OOD_BRAND_LINK_ACTIVE_BG_COLOR', 'BOOTSTRAP_NAVBAR_DEFAULT_LINK_ACTIVE_BG','BOOTSTRAP_NAVBAR_INVERSE_LINK_ACTIVE_BG' ).compact.first
    end
  end
end

# support custom initializers in /etc
if defined?(Rails) && defined?(Rails.application)
  Rails.application.configure do |config|
    config.paths["config/initializers"] << Configuration.config_root.join("initializers").to_s
  end
end
