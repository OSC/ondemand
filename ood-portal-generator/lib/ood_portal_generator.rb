require "dotenv"
require "etc"
require "pathname"
require "socket"

require "ood_portal_generator/version"
require "ood_portal_generator/application"
require "ood_portal_generator/view"
require "ood_portal_generator/dex"

# The main namespace for ood_portal_generator
module OodPortalGenerator
  class << self
    # Root path of this library
    # @return [Pathname] root path of library
    def root
      Pathname.new(__dir__).dirname
    end

    def os_release_file
      path = '/etc/os-release'
      return nil unless File.exist?(path)
      path
    end

    def scl_apache?
      return true if os_release_file.nil?
      env = Dotenv.parse(os_release_file)
      return false if ("#{env['ID']} #{env['ID_LIKE']}" =~ /rhel/ && env['VERSION_ID'] =~ /^8/)
      true
    end

    def fqdn
      Socket.gethostbyname(Socket.gethostname).first
    end

    # Determine dex username
    # @return [string] Return ondemand-dex if user exists, else process username
    def dex_user
      Etc.getpwnam('ondemand-dex').name
    rescue ArgumentError
      Etc.getlogin
    end

    # Determine dex group name
    # @return [string] Return ondemand-dex if group exists, else process group name
    def dex_group
      Etc.getgrnam('ondemand-dex').name
    rescue ArgumentError
      gid = Etc.getpwnam(Etc.getlogin).gid
      Etc.getgrgid(gid).name
    end

    def apache_group
      group = nil

      begin
        group = Etc.getgrnam('apache').name
      rescue ArgumentError
      end

      return group unless group.nil?

      begin
        group = Etc.getgrnam('www-data').name
      rescue ArgumentError
      end
      group
    end
  end
end
