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
    Pathname.new(ENV["OOD_APP_CONFIG"] || "/etc/ood/config/apps/myjobs")
  end

  def load_dotenv_files
    Dir.chdir app_root do
      # .env.local first, so it can override OOD_APP_CONFIG
      Dotenv.load(*dotenv_local_files) unless dotenv_local_files.empty?

      # load the rest of the dotenv files
      Dotenv.load(*dotenv_files)
    end
  end

  private

  # FIXME: if Rails is always guarenteed to be defined
  # here, including requiring from a bin/setup-production, then lets drop this
  #
  def rails_env
    (defined?(Rails) && Rails.env) || ENV['RAILS_ENV']
  end

  # FIXME: if Rails.root is always guarenteed to be defined
  # here, including in a bin/setup-production, then lets drop this
  #
  # The app's root directory
  # @return [Pathname] path to configuration root
  def app_root
    Pathname.new(File.expand_path("../../",  __FILE__))
  end

  def dotenv_local_files
    [
      (app_root.join(".env.#{rails_env}.local") unless rails_env.nil?),
      (app_root.join(".env.local") unless rails_env == "test"),
    ].compact
  end

  def dotenv_files
    [
      config_root.join("env"),
      (app_root.join(".env.#{rails_env}") unless rails_env.nil?),
      app_root.join(".env")
    ].compact
  end
end
