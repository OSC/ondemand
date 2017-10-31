require 'pathname'
require 'dotenv'

# dashboard app specific configuration
class Configuration
  extend ConfigRoot

  class << self
    attr_writer :app_development_enabled
    attr_writer :app_sharing_enabled

    # FIXME: temporary
    attr_accessor :app_sharing_facls_enabled
    alias_method :app_sharing_facls_enabled?, :app_sharing_facls_enabled

    def app_development_enabled?
      return @app_development_enabled if defined? @app_development_enabled
      ENV['OOD_APP_DEVELOPMENT'].present? || (defined?(DevRouter) && DevRouter.base_path.exist?)
    end
    alias_method :app_development_enabled, :app_development_enabled?

    def app_sharing_enabled?
      return @app_sharing_enabled if defined? @app_sharing_enabled
      @app_sharing_enabled = ENV['OOD_APP_SHARING'].present?
    end
    alias_method :app_sharing_enabled, :app_sharing_enabled?

    def custom_brand_bg_color
      return @custom_brand_bg_color if defined? @custom_brand_bg_color
      @custom_brand_bg_color = ENV.values_at('OOD_BRAND_BG_COLOR', 'BOOTSTRAP_NAVBAR_DEFAULT_BG', 'BOOTSTRAP_NAVBAR_INVERSE_BG').compact.first
    end

    def custom_brand_link_active_bg_color
      return @custom_brand_link_active_bg_color if defined? @custom_brand_link_active_bg_color
      @custom_brand_link_active_bg_color = ENV.values_at('OOD_BRAND_LINK_ACTIVE_BG_COLOR', 'BOOTSTRAP_NAVBAR_DEFAULT_LINK_ACTIVE_BG','BOOTSTRAP_NAVBAR_INVERSE_LINK_ACTIVE_BG' ).compact.first
    end
  end
end

# support custom initializers and views in /etc
Rails.application.configure do |config|
  config.paths["config/initializers"] << Configuration.config_root.join("config", "initializers").to_s
  config.paths["app/views"].unshift Configuration.config_root.join("app", "views").to_s
end
