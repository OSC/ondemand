#
# Manages profile based configuration properties.
# Property values are configured in configuration files under ::Configuration.config_directory and read from ::Configuration.config object.
#
# For backwards compatibility, properties can be configured to read values from the environment object: ENV.
# Environment values will have precedence over values defined in configuration files.
#
# Property lookup is hierarchical based on a profile value.
# The profile value will be the CurrentUser.user_settings[:profile] by default.
# This can be overridden using Configuration.host_based_profiles, in which case, the current request hostname will be used.
#
# First the lookup is done in the profile configuration if any, if no value is defined, the root configuration is used.
#
# Example configuration with a team1 profile:
#   dashboard_logo: "/public/ood.png"
#   profiles:
#     team1:
#       dashboard_logo: "/public/team1.png"
#
class UserConfiguration

  USER_PROPERTIES = [
    ConfigurationProperty.property(name: :dashboard_header_img_logo, read_from_env: true),
    # Whether we display the Dashboard logo image
    ConfigurationProperty.with_boolean_mapper(name: :disable_dashboard_logo, default_value: false, read_from_env: true, env_names: ['OOD_DISABLE_DASHBOARD_LOGO', 'DISABLE_DASHBOARD_LOGO']),
    # URL to the Dashboard logo image
    ConfigurationProperty.property(name: :dashboard_logo, read_from_env: true),
    # Dashboard logo height used to set the height style attribute
    ConfigurationProperty.property(name: :dashboard_logo_height, read_from_env: true),
    ConfigurationProperty.property(name: :brand_bg_color, read_from_env: true, env_names: ['OOD_BRAND_BG_COLOR', 'BOOTSTRAP_NAVBAR_DEFAULT_BG', 'BOOTSTRAP_NAVBAR_INVERSE_BG']),
    ConfigurationProperty.property(name: :brand_link_active_bg_color, read_from_env: true, env_names: ['OOD_BRAND_LINK_ACTIVE_BG_COLOR', 'BOOTSTRAP_NAVBAR_DEFAULT_LINK_ACTIVE_BG', 'BOOTSTRAP_NAVBAR_INVERSE_LINK_ACTIVE_BG']),

    # The dashboard's landing page layout. Defaults to nil.
    ConfigurationProperty.property(name: :dashboard_layout),
    # The configured pinned apps
    ConfigurationProperty.property(name: :pinned_apps, default_value: []),
    # The length of the "Pinned Apps" navbar menu
    ConfigurationProperty.property(name: :pinned_apps_menu_length, default_value: 6),
    ConfigurationProperty.property(name: :pinned_apps_group_by, default_value: nil, read_from_env: true),

    # Links to change profile under the Help navigation menu
    ConfigurationProperty.property(name: :profile_links, default_value: []),

    # Custom CSS files to add to the application.html.erb template
    # The files need to be deployed to the Apache public directory: /var/www/ood/public
    # The URL path will be prepended with the public_url property
    # example:
    # custom_css_files: ["core.css", "/custom/team1.css"]
    ConfigurationProperty.property(name: :custom_css_files, default_value: []),

    ConfigurationProperty.property(name: :dashboard_title, default_value: 'Open OnDemand', read_from_env: true),

    # Navigation properties
    ConfigurationProperty.with_boolean_mapper(name: :show_all_apps_link, default_value: false, read_from_env: true, env_names: ['SHOW_ALL_APPS_LINK']),
    # New navigation definition properties
    ConfigurationProperty.property(name: :nav_bar, default_value: []),
    ConfigurationProperty.property(name: :help_bar, default_value: []),
    ConfigurationProperty.property(name: :help_menu, default_value: []),
    ConfigurationProperty.property(name: :interactive_apps_menu, default_value: []),

    # Custom pages configuration property
    ConfigurationProperty.property(name: :custom_pages, default_value: {}),
  ].freeze

  def initialize(request_hostname: nil)
    @config = ::Configuration.config
    @request_hostname = request_hostname.to_sym if request_hostname
    add_property_methods
  end

  # Sets the Bootstrap 4 navbar type
  # See more about Bootstrap color schemes: https://getbootstrap.com/docs/4.6/components/navbar/#color-schemes
  # Supported values: ['dark', 'inverse', 'light', 'default']
  # @return [String, 'dark'] Default to dark
  def navbar_type
    type = ENV['OOD_NAVBAR_TYPE'] || fetch(:navbar_type)
    if type == 'inverse' || type == 'dark'
      'dark'
    elsif type == 'default' || type == 'light'
      'light'
    else
      'dark'
    end
  end

  def public_url
    path = ENV['OOD_PUBLIC_URL'] || fetch(:public_url, '/public')
    # do not load any resources using public_url from another host. Only allow relative paths.
    path.start_with?('/') ? Pathname.new(path) : Pathname.new('/public')
  end

  # Filtering is controlled with NavConfig.categories_allowlist? unless the configuration property categories is defined.
  # If categories are defined, filter_nav_categories? will always be true.
  def filter_nav_categories?
    fetch(:nav_categories, nil).nil? ? NavConfig.categories_whitelist? : true
  end

  def nav_categories
    fetch(:nav_categories, nil) || NavConfig.categories
  end

  # The current user profile. Used to select the configuration properties.
  def profile
    return CurrentUser.user_settings[:profile_override].to_sym if CurrentUser.user_settings[:profile_override]

    if Configuration.host_based_profiles
      request_hostname
    else
      CurrentUser.user_settings[:profile].to_sym if CurrentUser.user_settings[:profile]
    end
  end

  private

  # Performs the property lookup in the configuration object.
  # First, it looks into the profile configuration as defined by current user profile.
  # If no value is defined, it looks into the root configuration.
  def fetch(key_value, default_value = nil)
    key = key_value ? key_value.to_sym : nil
    profile_config = config.dig(:profiles, profile) || {}

    # Returns the value if they key is present in the profile, even if the value is nil
    # This is to mimic the Hash.fetch behaviour that only uses the default_value when key is not present
    profile_config.key?(key) ? profile_config[key].freeze : config.fetch(key, default_value).freeze
  end

  # Dynamically adds methods to this class based on the USER_PROPERTIES defined.
  # The name of the method is the name of the property.
  # The value is based on ENV and config objects, depending on the configuration of the property.
  def add_property_methods
    UserConfiguration::USER_PROPERTIES.each do |property|
      define_singleton_method(property.name) do
        environment_value = property.map_string(property.environment_names.map{|key| ENV[key]}.compact.first) if property.read_from_environment?
        environment_value.nil? ? fetch(property.name, property.default_value) : environment_value
      end
    end
  end

    private

    attr_reader :config, :request_hostname
end