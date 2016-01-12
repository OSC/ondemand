module NginxStage
  # An object that stores the configuration options to control NginxStage's
  # behavior.
  module Configuration
    # The reverse proxy daemon user used to access the sockets
    # @return [String] the reverse-proxy-daemon user
    attr_accessor :proxy_user

    # Location of ERB templates used as NGINX configs
    # @return [String] the ERB templates root path
    attr_accessor :template_root

    # Root location where per-user NGINX configs are generated
    # @return [String] root path of per-user NGINX configs
    attr_accessor :pun_config_root

    # Root location where NGINX app configs are generated
    # @return [String] root path of NGINX app configs
    attr_accessor :app_config_root

    # Root location where per-user NGINX generates its user tmp dirs
    # @return [String] the per-user NGINX tmp root
    attr_accessor :pun_tmp_root

    # Root location where per-user NGINX generates its user logs
    # @return [String] the per-user NGINX log root
    attr_accessor :pun_log_root

    # Root location where per-user NGINX generates user pid and socket files
    # @return [String] the per-user NGINX run root
    attr_accessor :pun_run_root

    # Path to system-installed NGINX mime.types config file
    # @return [String] the system-installed NGINX mime.types config
    attr_accessor :mime_types_path

    # Path to system-installed Passenger locations.ini file
    # @return [String] the system-installed Passenger locations.ini
    attr_accessor :passenger_root

    # Path to system-installed Ruby binary
    # @return [String] the system-installed Ruby binary
    attr_accessor :passenger_ruby

    # Path to system-installed NodeJS binary
    # @return [String] the system-installed NodeJS binary
    attr_accessor :passenger_nodejs

    # Path to system-installed NGINX binary
    # @return [String] the system-installed NGINX binary
    attr_accessor :nginx_bin

    # A whitelist of signals that can be sent to the NGINX process
    # @return [Array<Symbol>] whitelist of NGINX process signals
    attr_accessor :nginx_signals

    # @return [Hash] relative path wrt app root for given app environment
    # @see #app_config_root
    attr_accessor :app_root

    # App namespace that depends on the corresponding environment
    # @return [Hash] app namespace for given app environment
    attr_accessor :app_namespace

    # Regex that converts an app namespace to a corresponding app for the
    # corresponding environment
    # @see #app_namespace
    # @return [Hash] regex to determine app from app namespace for given
    #   environment
    attr_accessor :app_request_regex

    # Minimum user id required to run the per-user NGINX as this user. This
    # restricts running processes as special users (i.e., 'root')
    # @return [Integer] minimum user id required to run as user
    attr_accessor :min_uid

    # Modifies the library configuration
    # @yield The library configuration to the block
    def configure
      yield self
    end

    # Sets default configuration options in any class that extends {Configuration}
    def self.extended(base)
      base.set_default_configuration
    end

    # Sets the default configuration options
    def set_default_configuration
      self.proxy_user = 'apache'
      self.template_root = File.join(root, 'templates')
      self.pun_config_root = File.join('', 'var', 'lib', 'nginx', 'config')
      self.app_config_root = File.join('', 'var', 'lib', 'nginx', 'config')
      self.pun_tmp_root = File.join('', 'var', 'lib', 'nginx', 'tmp')
      self.pun_log_root = File.join('', 'var', 'log', 'nginx')
      self.pun_run_root = File.join('', 'var', 'run', 'nginx')
      self.mime_types_path = '/opt/rh/nginx16/root/etc/nginx/mime.types'
      self.passenger_root = '/opt/rh/rh-passenger40/root/usr/share/passenger/phusion_passenger/locations.ini'
      self.passenger_ruby = '/opt/rh/rh-ruby22/root/usr/bin/ruby'
      self.passenger_nodejs = '/opt/rh/nodejs010/root/usr/bin/node'
      self.nginx_bin = '/opt/rh/nginx16/root/usr/sbin/nginx'
      self.nginx_signals = %i(stop quit reopen reload)
      self.app_root = {
        dev: File.join('~%{owner}', 'ood_dev'),
        shared: File.join('~%{owner}', 'ood_shared')
      }
      self.app_namespace = {
        dev: '%{app}',
        shared: '%{owner}/%{app}'
      }
      self.app_request_regex = {
        dev: %r[^/(?<app>[\w-]+)],
        shared: %r[^/(?<owner>[\w-]+)/(?<app>[\w-]+)]
      }
      self.min_uid = 1000
    end
  end
end
