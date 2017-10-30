require 'pathname'
require 'dotenv'

Pathname.new(File.expand_path("../../",  __FILE__)).tap do |root|
  Dir.chdir root do
    default_config = '/etc/ood/config/apps/dashboard/env'
    rails_env = (defined?(Rails) && Rails.env) || ENV['RAILS_ENV']

    # .env.local first, so it can override OOD_APP_CONFIG
    dotenv_files = [
      (root.join(".env.#{rails_env}.local") unless rails_env.nil?),
      (root.join(".env.local") unless rails_env == "test"),
    ].compact
    Dotenv.load(*dotenv_files) unless dotenv_files.empty?

    # load the rest of the dotenv files
    dotenv_files = [
      "#{ENV['OOD_APP_CONFIG']}/env" || default_config,
      root.join(".env.#{rails_env}"),
      root.join(".env")
    ].compact
    Dotenv.load(*dotenv_files)
  end
end
