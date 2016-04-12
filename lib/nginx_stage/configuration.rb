require 'yaml'

module NginxStage
  # An object that stores the configuration options to control NginxStage's
  # behavior.
  module Configuration
    #
    # Templates
    #

    # Location of ERB templates used as NGINX configs
    # @return [String] the ERB templates root path
    attr_accessor :template_root

    #
    # NGINX-specific configuration options
    #

    # The reverse proxy daemon user used to access the sockets
    # @return [String] the reverse-proxy-daemon user
    attr_accessor :proxy_user

    # Path to system-installed NGINX binary
    # @return [String] the system-installed NGINX binary
    attr_accessor :nginx_bin

    # A whitelist of signals that can be sent to the NGINX process
    # @return [Array<Symbol>] whitelist of NGINX process signals
    attr_accessor :nginx_signals

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

    #
    # per-user NGINX configuration options
    #

    # Root location where per-user NGINX configs are generated
    # Path to generated per-user NGINX config file
    # @example User Bob's nginx config
    #   pun_config_path(user: 'bob')
    #   #=> "/var/log/nginx/config/puns/bob.conf"
    # @param user [String] the user of the nginx process
    # @return [String] the path to the per-user nginx config file
    def pun_config_path(user:)
      File.expand_path @pun_config_path % {user: user}
    end

    attr_writer :pun_config_path

    # Path to user's personal tmp root (this root will be owned by the user)
    # @example User Bob's nginx tmp root
    #   pun_tmp_root(user: 'bob')
    #   #=> "/var/lib/nginx/tmp/bob"
    # @param user [String] the user of the nginx process
    # @return [String] the path to the tmp root
    def pun_tmp_root(user:)
      File.expand_path @pun_tmp_root % {user: user}
    end

    attr_writer :pun_tmp_root

    # Path to the user's personal access.log
    # @example User Bob's nginx access log
    #   pun_access_log_path(user: 'bob')
    #   #=> "/var/log/nginx/bob/access.log"
    # @param user [String] the user of the nginx process
    # @return [String] the path to the nginx access log
    def pun_access_log_path(user:)
      File.expand_path @pun_access_log_path % {user: user}
    end

    attr_writer :pun_access_log_path

    # Path to the user's personal error.log
    # @example User Bob's nginx error log
    #   pun_error_log_path(user: 'bob')
    #   #=> "/var/log/nginx/bob/error.log"
    # @param user [String] the user of the nginx process
    # @return [String] the path to the nginx error log
    def pun_error_log_path(user:)
      File.expand_path @pun_error_log_path % {user: user}
    end

    attr_writer :pun_error_log_path

    # Path to the user's per-user NGINX pid file
    # @example User Bob's pid file
    #   pun_pid_path(user: 'bob')
    #   #=> "/var/run/nginx/bob/passenger.pid"
    # @param user [String] the user of nginx process
    # @return [String] the path to the pid file
    def pun_pid_path(user:)
      File.expand_path @pun_pid_path % {user: user}
    end

    attr_writer :pun_pid_path

    # Path to the user's per-user NGINX socket file
    # @example User Bob's socket file
    #   socket_path(user: 'bob')
    #   #=> "/var/run/nginx/bob/passenger.sock"
    # @param user [String] the user of nginx process
    # @return [String] the path to the socket file
    def pun_socket_path(user:)
      File.expand_path @pun_socket_path % {user: user}
    end

    attr_writer :pun_socket_path

    #
    # per-user NGINX app configuration options
    #

    # Path to generated NGINX app config
    # @example Dev app owned by Bob
    #   app_config_path(env: :dev, owner: 'bob', name: 'rails1')
    #   #=> "/var/lib/nginx/config/apps/dev/bob/rails1.conf"
    # @example Shared app owned by Dan
    #   app_config_path(env: :shared, owner: 'dan', name: 'fillsim')
    #   #=> "/var/lib/nginx/config/apps/shared/dan/fillsim.conf"
    # @param env [Symbol] environment the app is run under
    # @param owner [String] the owner of the app
    # @param name [String] the name of the app
    # @return [String] the path to the nginx app config on the local filesystem
    def app_config_path(env:, owner:, name:)
      File.expand_path @app_config_path[env] % {env: env, owner: owner, name: name}
    end

    attr_writer :app_config_path

    # Path to the app root on the local filesystem
    # @example App root for dev app owned by Bob
    #   app_root(env: :dev, owner: 'bob', name: 'rails1')
    #   #=> "~bob/ood_dev/rails1"
    # @example App root for shared app owned by Dan
    #   app_root(env: :shared, owner: 'dan', name: 'fillsim')
    #   #=> "~dan/ood_shared/fillsim"
    # @param env [Symbol] environment the app is run under
    # @param owner [String] the owner of the app
    # @param name [String] the name of the app
    # @return [String] the path to the app root on the local filesystem
    # @raise [InvalidRequest] if the environment specified doesn't exist
    def app_root(env:, owner:, name:)
      File.expand_path(
        @app_root.fetch(env) do
          raise InvalidRequest, "invalid request environment: #{env}"
        end % {env: env, owner: owner, name: name}
      )
    end

    attr_writer :app_root

    # The URI used to access the app from the browser, not including any base-uri
    # @example URI for dev app owned by Bob
    #   app_request_uri(env: :dev, owner: 'bob', name: 'rails1')
    #   #=> "/dev/rails1"
    # @example URI for shared app owned by Dan
    #   app_request_uri(env: :dev, owner: 'dan', name: 'fillsim')
    #   #=> "/shared/dan/fillsim"
    # @param env [Symbol] environment the app is run under
    # @param owner [String] the owner of the app
    # @param name [String] the name of the app
    # @return [String] the URI used to access a given app
    # @raise [InvalidRequest] if the environment specified doesn't exist
    def app_request_uri(env:, owner:, name:)
      @app_request_uri.fetch(env) do
        raise InvalidRequest, "invalid request environment: #{env}"
      end % {env: env, owner: owner, name: name}
    end

    attr_writer :app_request_uri

    # Regular expression used to distinguish the environment from a request URI
    # and from there distinguish the app owner and app name
    # @see #app_request_uri
    # @return [Hash] hash of regular expressions used to determine app from app
    #   namespace for given environment
    def app_request_regex
      @app_request_regex.each_with_object({}) { |(k, v), h| h[k] = ::Regexp.new v }
    end

    attr_writer :app_request_regex

    #
    # Validation configuration options
    #

    # Minimum user id required to run the per-user NGINX as this user. This
    # restricts running processes as special users (i.e., 'root')
    # @return [Integer] minimum user id required to run as user
    attr_accessor :min_uid

    #
    # Configuration module
    #

    # Default configuration file
    # @return [String] path to default yaml configuration file
    def default_config_path
      File.join root, 'config', 'nginx_stage.yml'
    end

    # Yields the configuration object.
    # @yieldparam [Configuration] config The library configuration
    # @return [void]
    def configure
      yield self
    end

    # Sets default configuration options in any class that extends {Configuration}
    def self.extended(base)
      base.set_default_configuration
    end

    # Sets the default configuration options
    # @return [void]
    def set_default_configuration
      self.template_root = "#{root}/templates"

      self.proxy_user       = 'apache'
      self.nginx_bin        = '/opt/rh/nginx16/root/usr/sbin/nginx'
      self.nginx_signals    = %i(stop quit reopen reload)
      self.mime_types_path  = '/opt/rh/nginx16/root/etc/nginx/mime.types'
      self.passenger_root   = '/opt/rh/rh-passenger40/root/usr/share/passenger/phusion_passenger/locations.ini'
      self.passenger_ruby   = '/opt/rh/rh-ruby22/root/usr/bin/ruby'
      self.passenger_nodejs = '/opt/rh/nodejs010/root/usr/bin/node'

      self.pun_config_path     = '/var/lib/nginx/config/puns/%{user}.conf'
      self.pun_tmp_root        = '/var/lib/nginx/tmp/%{user}'
      self.pun_access_log_path = '/var/log/nginx/%{user}/access.log'
      self.pun_error_log_path  = '/var/log/nginx/%{user}/error.log'
      self.pun_pid_path        = '/var/run/nginx/%{user}/passenger.pid'
      self.pun_socket_path     = '/var/run/nginx/%{user}/passenger.sock'

      self.app_config_path   = {
        dev:    '/var/lib/nginx/config/apps/%{env}/%{user}/%{name}.conf',
        shared: '/var/lib/nginx/config/apps/%{env}/%{user}/%{name}.conf'
      }
      self.app_root          = {
        dev:    '~%{owner}/ood_%{env}/%{name}',
        shared: '~%{owner}/ood_%{env}/%{name}'
      }
      self.app_request_uri   = {
        dev:    '/dev/%{name}',
        shared: '/shared/%{owner}/%{name}'
      }
      self.app_request_regex = {
        dev:    '^/dev/(?<name>[-\w.]+)',
        shared: '^/shared/(?<owner>[\w]+)/(?<name>[-\w.]+)'
      }

      self.min_uid = 1000

      read_configuration(default_config_path) if File.file?(default_config_path)
    end

    # Read in a configuration from a file
    # @param file [String] path to the yaml configuration file
    # @return [void]
    def read_configuration(file)
      config_hash = YAML.load_file(file)
      config_hash.each do |k,v|
        if instance_variable_defined? "@#{k}"
          self.send("#{k}=", v)
        else
          raise InvalidConfigOption, "invalid configuration option: #{k}"
        end
      end
    end
  end
end
