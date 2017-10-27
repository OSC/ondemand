# dashboard app specific configuration
class Configuration
  class << self
    attr_writer :app_development_enabled
    attr_writer :app_sharing_enabled

    attr_accessor :banner_bg
    attr_accessor :banner_color

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
  end

  # setup default values for banner
  # self.banner_bg = '#e9e9e9'
  # self.banner_color = '#737373'
  self.banner_bg = lambda {
    if ENV['OOD_NAVBAR_TYPE'] == 'default'
      ENV['BOOTSTRAP_NAVBAR_DEFAULT_BG'] || '#f8f8f8'
    else
      ENV['BOOTSTRAP_NAVBAR_INVERSE_BG'] || '#53565a'
    end
  }.call
  self.banner_color = lambda {
    if ENV['OOD_NAVBAR_TYPE'] == 'default'
      ENV['BOOTSTRAP_NAVBAR_DEFAULT_LINK_COLOR'] || '#777'
    else
      ENV['BOOTSTRAP_NAVBAR_INVERSE_LINK_COLOR'] || '#fff'
    end
  }.call
end
