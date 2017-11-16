require 'pathname'
require 'dotenv'

module ConfigRoot
  # make these methods also callable directly
  # see for discussion on extend self vs module_function:
  # https://github.com/bbatsov/ruby-style-guide/issues/556
  extend self

  # The app's configuration root directory
  # @return [Pathname] path to configuration root
  def config_root
    Pathname.new(ENV["OOD_APP_CONFIG_ROOT"] || "/etc/ood/config/apps/dashboard")
  end

  def initializers_root
    Pathname.new(ENV["OOD_APP_INITIALIZERS_ROOT"] || config_root.join("initializers"))
  end

  def load_external_config?
    ENV['OOD_LOAD_EXTERNAL_CONFIG'] || rails_env == "production"
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
    Dotenv.load(*dotenv_local_files) unless dotenv_local_files.empty?

    # load the rest of the dotenv files
    Dotenv.load(*dotenv_files)
  end

  private

  # The environment
  # @return [String] "development", "test", or "production"
  def rails_env
    ENV['RAILS_ENV'] || "development"
  end

  # The app's root directory
  # @return [Pathname] path to configuration root
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
end
