require 'pathname'
require 'dotenv'

# Job Composer app specific configuration singleton definition
#
# following the first proposal in:
#
# https://8thlight.com/blog/josh-cheek/2012/10/20/implementing-and-testing-the-singleton-pattern-in-ruby.html
#
# to avoid the traditional singleton approach or using class methods, both of
# which make it difficult to write tests against
#
# instead, ConfigurationSingleton is the definition of the configuration
# then the singleton instance used is a new class called "Configuration" which
# we set in config/boot i.e.
#
# Configuration = ConfigurationSingleton.new
#
# This is functionally equivalent to taking every instance method on
# ConfigurationSingleton and defining it as a class method on Configuration.
#
class ConfigurationSingleton

  # The app's configuration root directory
  # @return [Pathname] path to configuration root
  def config_root
    Pathname.new(ENV["OOD_APP_CONFIG_ROOT"] || "/etc/ood/config/apps/myjobs")
  end

  def custom_initializers_root
    config_root.join("initializers")
  end

  def custom_views_root
    config_root.join("views")
  end

  def load_external_config?
    to_bool(ENV.fetch('OOD_LOAD_EXTERNAL_CONFIG', (rails_env == 'production')))
  end

  # Custom job templates source directory in /etc/.../myjobs/templates
  # Defaults to APPROOT/templates if that directory exists or if
  # not in production.
  #
  # @return [Pathname] path to templates root
  def templates_path
    default = app_root.join('templates')

    if (! default.directory?) && load_external_config?
      config_root.join("templates")
    else
      default
    end
  end

  def show_job_options_account_field?
    to_bool(ENV.fetch('OOD_SHOW_JOB_OPTIONS_ACCOUNT_FIELD', true))
  end

  # Override variable for (not) showing job array in the job composer
  def hide_job_arrays?
    to_bool(ENV.fetch('OOD_HIDE_JOB_ARRAYS', false))
  end

  # Load the dotenv local files first, then the /etc dotenv files and
  # the .env and .env.production or .env.development files.
  #
  # Doing this in two separate loads means OOD_APP_CONFIG_ROOT can be specified in
  # the .env.local file, which will specify where to look for the /etc dotenv
  # files. The default for OOD_APP_CONFIG_ROOT is /etc/ood/config/apps/myjobs and
  # both .env and .env.production will be searched for there.
  def load_dotenv_files
    # .env.local first, so it can override OOD_APP_CONFIG_ROOT
    Dotenv.load(*dotenv_local_files)

    # load the rest of the dotenv files
    Dotenv.load(*dotenv_files)

    # load overloads
    Dotenv.overload(*(overload_files(dotenv_files)))
    Dotenv.overload(*(overload_files(dotenv_local_files)))
  end

  def dataroot
    # copied from OodAppkit::Configuration#set_default_configuration
    # then modified to ensure dataroot is never nil
    #
    # FIXME: note that this would be invalid if the dataroot where
    # overridden in an initializer by modifying OodAppkit.dataroot
    # Solution: in a test, add a custom initializer that changes this, then verify it has
    # no effect or it affects both.
    #
    root = ENV['OOD_DATAROOT'] || ENV['RAILS_DATAROOT']
    if rails_env == "production"
      root ||= "~/#{ENV['OOD_PORTAL'] || 'ondemand'}/data/#{ENV['APP_TOKEN'] || 'sys/myjobs'}"
    else
      root ||= app_root.join("data")
    end

    Pathname.new(root).expand_path
  end

  def production_database_path
    # FIXME: add support/handling for DATABASE_URL
    Pathname.new(ENV["DATABASE_PATH"] || dataroot.join('production.sqlite3')).expand_path
  end

  def whitelist_paths
    (ENV['OOD_ALLOWLIST_PATH'] || ENV['WHITELIST_PATH'] || "").split(':')
  end

  def locale
    (ENV['OOD_LOCALE'] || I18n.default_locale).to_sym
  end

  def locales_root
    Pathname.new(ENV['OOD_LOCALES_ROOT'] || "/etc/ood/config/locales")
  end

  # Permit sites to disable Markdown rendering of Template notes
  def render_template_notes_as_markdown?
    preference = ENV['RENDER_TEMPLATE_NOTES_AS_MARKDOWN']

    if preference.nil?
      true
    else
      to_bool(preference)
    end
  end

  def brand_bg_color
    ENV.values_at('OOD_BRAND_BG_COLOR', 'BOOTSTRAP_NAVBAR_DEFAULT_BG', 'BOOTSTRAP_NAVBAR_INVERSE_BG').compact.first
  end

  def brand_link_active_bg_color
    ENV.values_at('OOD_BRAND_LINK_ACTIVE_BG_COLOR', 'BOOTSTRAP_NAVBAR_DEFAULT_LINK_ACTIVE_BG','BOOTSTRAP_NAVBAR_INVERSE_LINK_ACTIVE_BG' ).compact.first
  end

  def max_valid_script_size_kb
    (ENV['OOD_MAX_SCRIPT_SIZE_KB'] || 65).to_i
  end

  # The XMoD host
  # @return [String, null] the host, or null if not set
  def xdmod_host
    ENV["OOD_XDMOD_HOST"]
  end

  # Whether or not XDMoD integration is enabled
  # @return [Boolean]
  def xdmod_integration_enabled?
    xdmod_host.present?
  end

  private

  # The environment
  # @return [String] "development", "test", or "production"
  def rails_env
    ENV['RAILS_ENV'] || ENV['RACK_ENV'] || "development"
  end

  # The app's root directory
  # @return [Pathname] path to app root
  def app_root
    Pathname.new(File.expand_path("../../",  __FILE__))
  end

  def dotenv_local_files
    [
      app_root.join(".env.#{rails_env}.local"),
      (app_root.join(".env.local") unless rails_env == "test"),
    ].compact
  end

  def dotenv_files
    [
      (config_root.join("env") if load_external_config?),
      app_root.join(".env.#{rails_env}"),
      app_root.join(".env")
    ].compact
  end

  # reverse list and suffix every path with '.overload'
  def overload_files(files)
    files.reverse.map {|p| p.sub(/$/, '.overload')}
  end

  FALSE_VALUES=[nil, false, '', 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF', 'no', 'NO']

  # Bool conversion pulled from ActiveRecord::Type::Boolean#cast_value
  #
  # @return [Boolean] false for falsy value, true for everything else
  def to_bool(value)
    ! FALSE_VALUES.include?(value)
  end
end
