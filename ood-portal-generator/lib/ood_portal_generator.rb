# frozen_string_literal: true

require 'dotenv'
require 'etc'
require 'pathname'
require 'socket'

require 'ood_portal_generator/version'
require 'ood_portal_generator/application'
require 'ood_portal_generator/view'
require 'ood_portal_generator/dex'

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

    def debian?
      return false if os_release_file.nil?

      env = Dotenv.parse(os_release_file)
      return true if env['ID'] =~ /(ubuntu|debian)/ || (env['ID_LIKE'] == 'debian')

      false
    end

    def fqdn
      Addrinfo.getaddrinfo(Socket.gethostname, nil, :INET, :STREAM, nil, Socket::AI_CANONNAME).first.canonname
    end

    # Determine dex username
    # @return [string] Return ondemand-dex if user exists, else process username
    def dex_user
      Etc.getpwnam('ondemand-dex').name
    rescue ArgumentError
      Etc.getpwuid.name
    end

    # Determine dex group name
    # @return [string] Return ondemand-dex if group exists, else process group name
    def dex_group
      Etc.getgrnam('ondemand-dex').name
    rescue ArgumentError
      gid = Etc.getpwuid.gid
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

    def chown_apache_user
      return 'root' if Process.uid.zero?

      Etc.getpwuid(Process.uid).name
    end
  end
end
