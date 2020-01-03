require 'pathname'
require 'dotenv'

# Dashboard app specific configuration singleton definition
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
  attr_writer :app_development_enabled
  attr_writer :app_sharing_enabled

  # FIXME: temporary
  attr_accessor :app_sharing_facls_enabled
  alias_method :app_sharing_facls_enabled?, :app_sharing_facls_enabled

  # @return [String] memoized version string
  def app_version
    @app_version ||= (version_from_file(Rails.root) || version_from_git(Rails.root) || "Unknown").strip
  end

  # @return [String] memoized version string
  def ood_version
    @ood_version ||= (ood_version_from_env || version_from_file('/opt/ood') || version_from_git('/opt/ood') || "Unknown").strip
  end

def ood_bc_ssh_to_compute_node
  to_bool(ENV['OOD_BC_SSH_TO_COMPUTE_NODE'] || true)
end

  # @return [String, nil] version string from git describe, or nil if not git repo
  def version_from_git(dir)
    Dir.chdir(Pathname.new(dir)) do
      version = `git describe --always --tags 2>/dev/null`
      version.blank? ? nil : version
    end
  rescue Errno::ENOENT
    nil
  end

  # @return [String, nil] version string from VERSION file, or nil if no file avail
  def version_from_file(dir)
    file = Pathname.new(dir).join("VERSION")
    file.read if file.file?
  end

  def ood_version_from_env
    ENV['OOD_VERSION'] || ENV['ONDEMAND_VERSION']
  end

  # The app's configuration root directory
  # @return [Pathname] path to configuration root
  def config_root
    Pathname.new(ENV["OOD_APP_CONFIG_ROOT"] || "/etc/ood/config/apps/dashboard")
  end

  def load_external_config?
    to_bool(ENV['OOD_LOAD_EXTERNAL_CONFIG'] || (rails_env == 'production'))
  end

  # The root directory that holds configuration information for Batch Connect
  # apps (typically each app will have a sub-directory underneath this)
  def bc_config_root
    Pathname.new(ENV["OOD_BC_APP_CONFIG_ROOT"] || "/etc/ood/config/apps")
  end

  def load_external_bc_config?
    to_bool(ENV["OOD_LOAD_EXTERNAL_BC_CONFIG"] || (rails_env == "production"))
  end

  # The file system path to the announcements
  # @return [Pathname, Array<Pathname>] announcement path or paths
  def announcement_path
    if path = ENV["OOD_ANNOUNCEMENT_PATH"]
      Pathname.new(path)
    else
      [
        "/etc/ood/config/announcement.md",
        "/etc/ood/config/announcement.yml",
        "/etc/ood/config/announcements.d"
      ].map {|p| Pathname.new(p)}
    end
  end

  # The paths to the JSON files that store the quota information
  # Can be URL or File path. colon delimited string; though colon in URL is
  # ignored if URL has format: scheme://path (colons preceeding // are ignored)
  #
  # /path/to/quota.json:https://osc.edu/quota.json
  #
  #
  # @return [Array<String>] quota paths
  def quota_paths
    # regex uses negative lookahead to ignore : preceeding //
    ENV.fetch("OOD_QUOTA_PATH", "").strip.split(/:(?!\/\/)/)
  end

  # The threshold for determining if there is sufficient quota remaining
  # @return [Float] threshold factor
  def quota_threshold
    ENV.fetch("OOD_QUOTA_THRESHOLD", 0.95).to_f
  end

  # The paths to the JSON files that store the balance information
  # Can be URL or File path. colon delimited string; though colon in URL is
  # ignored if URL has format: scheme://path (colons preceeding // are ignored)
  #
  # /path/to/balance.json:https://osc.edu/balance.json
  #
  #
  # @return [Array<String>] balance paths
  def balance_paths
    # regex uses negative lookahead to ignore : preceeding //
    ENV.fetch("OOD_BALANCE_PATH", "").strip.split(/:(?!\/\/)/)
  end

  # The threshold for determining if there is sufficient balance remaining
  # @return [Float] threshold factor
  def balance_threshold
    ENV.fetch("OOD_BALANCE_THRESHOLD", 0).to_f
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
  end

  def dev_apps_root_path
    Pathname.new(ENV["OOD_DEV_APPS_ROOT"] || "/dev/null")
  end

  def app_development_enabled?
    return @app_development_enabled if defined? @app_development_enabled
    to_bool(ENV['OOD_APP_DEVELOPMENT'] || DevRouter.base_path.directory? || DevRouter.base_path.symlink?)
  end
  alias_method :app_development_enabled, :app_development_enabled?

  def app_sharing_enabled?
    return @app_sharing_enabled if defined? @app_sharing_enabled
    @app_sharing_enabled = to_bool(ENV['OOD_APP_SHARING'])
  end
  alias_method :app_sharing_enabled, :app_sharing_enabled?

  # URL to the Dashboard logo image
  # @return [String, nil] URL of logo image
  def logo_img
    ENV["OOD_DASHBOARD_LOGO"]
  end

  # Whether we display the Dashboard logo image
  # @return [Boolean] whether display logo image
  def logo_img?
    !to_bool(ENV["DISABLE_DASHBOARD_LOGO"])
  end

  def brand_bg_color
    ENV.values_at('OOD_BRAND_BG_COLOR', 'BOOTSTRAP_NAVBAR_DEFAULT_BG', 'BOOTSTRAP_NAVBAR_INVERSE_BG').compact.first
  end

  def brand_link_active_bg_color
    ENV.values_at('OOD_BRAND_LINK_ACTIVE_BG_COLOR', 'BOOTSTRAP_NAVBAR_DEFAULT_LINK_ACTIVE_BG','BOOTSTRAP_NAVBAR_INVERSE_LINK_ACTIVE_BG' ).compact.first
  end

  def show_all_apps_link?
    to_bool(ENV['SHOW_ALL_APPS_LINK'])
  end

  def developer_docs_url
    ENV['OOD_DASHBOARD_DEV_DOCS_URL'] || "https://go.osu.edu/ood-app-dev"
  end

  def dataroot
    # copied from OodAppkit::AppConfig#set_default_configuration
    # then modified to ensure dataroot is never nil
    #
    # FIXME: note that this would be invalid if the dataroot where
    # overridden in an initializer by modifying OodAppkit.dataroot
    # Solution: in a test, add a custom initializer that changes this, then verify it has
    # no effect or it affects both.
    #
    root = ENV['OOD_DATAROOT'] || ENV['RAILS_DATAROOT']
    if rails_env == "production"
      root ||= "~/#{ENV['OOD_PORTAL'] || 'ondemand'}/data/#{ENV['APP_TOKEN'] || 'sys/dashboard'}"
    else
      root ||= app_root.join("data")
    end

    Pathname.new(root).expand_path
  end

  def locale
    (ENV['OOD_LOCALE'] || I18n.default_locale).to_sym
  end

  def locales_root
    Pathname.new(ENV['OOD_LOCALES_ROOT'] || "/etc/ood/config/locales")
  end

  def sanitize_bc_job_names?
    to_bool(ENV['OOD_SANITIZE_BC_JOB_NAMES'])
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

  FALSE_VALUES=[nil, false, '', 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF', 'no', 'NO']

  # Bool coersion pulled from ActiveRecord::Type::Boolean#cast_value
  #
  # @return [Boolean] false for falsy value, true for everything else
  def to_bool(value)
    ! FALSE_VALUES.include?(value)
  end
end
