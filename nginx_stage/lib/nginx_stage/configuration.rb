require 'yaml'
require 'etc'
require 'pathname'
require 'dotenv'

module NginxStage
  # An object that stores the configuration options to control NginxStage's
  # behavior.
  module Configuration
    #
    # Global
    #

    # Path to the OnDemand version file that contains version of OnDemand
    # installed
    # @return [String] the ondemand version file
    attr_accessor :ondemand_version_path

    # Unique name of OnDemand portal for namespacing multiple portals
    # @return [String, nil] the name of OnDemand portal if defined
    attr_accessor :ondemand_portal

    # Title of the OnDemand portal that apps *should* display in their navbar
    # @return [String, nil] the title of the Dashboard if defined
    attr_accessor :ondemand_title

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

    # An allowlist of signals that can be sent to the NGINX process
    # @return [Array<Symbol>] allowlist of NGINX process signals
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

    # Path to system-installed python binary
    # @return [String] the system-installed python binary
    attr_accessor :passenger_python

    # The maximum number of seconds that an application process may be idle.
    # @return [Integer] the value for passenger_pool_idle_time
    attr_accessor :passenger_pool_idle_time

    # Path to the user's Passenger log file
    # @example User Bob's Passenger log
    #   passenger_log_file(user: 'bob')
    #   #=> "/var/log/ondemand-nginx/bob/passenger.log"
    # @param user [String] the user of the nginx process
    # @return [String, nil] the path to the Passenger log file for user user
    def passenger_log_file(user:)
      # Uses nginx error log if nil
      @passenger_log_file&.%({ user: user })
    end

    # Option to disable the Passenger telemetry
    # @return [String] the value for passenger_disable_anonymous_telemetry
    attr_accessor :passenger_disable_anonymous_telemetry

    attr_writer :passenger_log_file

    # Hash of Passenger configuration options
    # @return [Hash] Hash of Passenger configuration options
    attr_writer :passenger_options

    def passenger_options
      # Ensure that all options begin with passenger_
      @passenger_options.select { |key, value| key.to_s.start_with?('passenger_') }
    end

    #
    # per-user NGINX configuration options
    #

    # Max file upload size (e.g., 10737420000)
    # @return [String] the max file size clients can upload in bytes
    attr_accessor :nginx_file_upload_max

    # Custom environment variables to set in the PUN
    # @return [Hash<String, String>] custom env var key and value pairs
    attr_writer :pun_custom_env

    def pun_custom_env
      # Ensure that both keys and values are strings to avoid a crash when
      # rendering the template
      Hash[@pun_custom_env.map {|key, value| [key.to_s, value.to_s]}]
    end

    # Custom environment variables to pass to the PUN using NGINX env directive
    # @return [Array<String>] the array of env var names
    attr_accessor :pun_custom_env_declarations

    # Path to generated per-user NGINX config file
    # @example User Bob's nginx config
    #   pun_config_path(user: 'bob')
    #   #=> "/var/lib/ondemand-nginx/config/puns/bob.conf"
    # @param user [String] the user of the nginx process
    # @return [String] the path to the per-user nginx config file
    def pun_config_path(user:)
      File.expand_path @pun_config_path % {user: user}
    end

    attr_writer :pun_config_path

    # Path to generated per-user secret key base file
    # @example User Bob's secret key base file
    #   pun_config_path(user: 'bob')
    #   #=> "/var/lib/ondemand-nginx/config/puns/bob.secret_key_base.txt"
    # @param user [String] the user of the nginx process
    # @return [String] the path to the per-user nginx config file
    def pun_secret_key_base_path(user:)
      File.expand_path @pun_secret_key_base_path % {user: user}
    end

    attr_writer :pun_secret_key_base_path

    # Path to user's personal tmp root
    # @example User Bob's nginx tmp root
    #   pun_tmp_root(user: 'bob')
    #   #=> "/var/lib/ondemand-nginx/tmp/bob"
    # @param user [String] the user of the nginx process
    # @return [String] the path to the tmp root
    def pun_tmp_root(user:)
      File.expand_path @pun_tmp_root % {user: user}
    end

    attr_writer :pun_tmp_root

    # Path to the user's personal access.log
    # @example User Bob's nginx access log
    #   pun_access_log_path(user: 'bob')
    #   #=> "/var/log/ondemand-nginx/bob/access.log"
    # @param user [String] the user of the nginx process
    # @return [String] the path to the nginx access log
    def pun_access_log_path(user:)
      expand_nginx_log_path @pun_access_log_path % {user: user}
    end

    attr_writer :pun_access_log_path

    # Path to the user's personal error.log
    # @example User Bob's nginx error log
    #   pun_error_log_path(user: 'bob')
    #   #=> "/var/log/ondemand-nginx/bob/error.log"
    # @param user [String] the user of the nginx process
    # @return [String] the path to the nginx error log
    def pun_error_log_path(user:)
      expand_nginx_log_path @pun_error_log_path % {user: user}
    end

    attr_writer :pun_error_log_path

    # Access log custom format
    # @return [String] format parameters
    attr_accessor :pun_log_format

    # Path to the user's per-user NGINX pid file
    # @example User Bob's pid file
    #   pun_pid_path(user: 'bob')
    #   #=> "/var/run/ondemand-nginx/bob/passenger.pid"
    # @param user [String] the user of nginx process
    # @return [String] the path to the pid file
    def pun_pid_path(user:)
      File.expand_path @pun_pid_path % {user: user}
    end

    attr_writer :pun_pid_path

    # Path to the user's per-user NGINX socket file
    # @example User Bob's socket file
    #   socket_path(user: 'bob')
    #   #=> "/var/run/ondemand-nginx/bob/passenger.sock"
    # @param user [String] the user of nginx process
    # @return [String] the path to the socket file
    def pun_socket_path(user:)
      File.expand_path @pun_socket_path % {user: user}
    end

    attr_writer :pun_socket_path

    # Path to the local filesystem root where the per-user Nginx serves files
    # from with the sendfile feature
    # @example Filesystem root for user Bob
    #   pun_sendfile_root(user: 'bob')
    #   #=> "/"
    # @param user [String] the user of the nginx process
    # @return [String] the path to the filesystem root that is served
    def pun_sendfile_root(user:)
      File.expand_path @pun_sendfile_root % {user: user}
    end

    attr_writer :pun_sendfile_root

    # The internal URI used to access the filesystem for downloading files from
    # the browser, not including any base-uri
    # @example
    #   pun_sendfile_uri
    #   #=> "/sendfile"
    # @return [String] the internal URI used to access filesystem
    attr_accessor :pun_sendfile_uri

    # List of hashes that help define the location of the app configs for the
    # per-user NGINX config. These will be arguments for {#app_config_path}.
    # @example User Bob's app configs
    #   pun_app_configs(user: 'bob')
    #   #=> [ {env: :dev, owner: 'bob', name: '*'},
    #         {env: :usr, owner: '*', name: '*'} ]
    # @param user [String] the user of the nginx process
    # @return [Array<Hash>] list of hashes detailing app config locations
    def pun_app_configs(user:)
      @pun_app_configs.map do |envmt|
        envmt.each_with_object({}) do |(k, v), h|
          h[k] = v.respond_to?(:%) ? (v % {user: user}) : v
          h[k] = v.to_sym if k == :env
        end
      end
    end

    attr_writer :pun_app_configs

    #
    # per-user NGINX app configuration options
    #

    # Path to generated NGINX app config
    # @example Dev app owned by Bob
    #   app_config_path(env: :dev, owner: 'bob', name: 'rails1')
    #   #=> "/var/lib/ondemand-nginx/config/apps/dev/bob/rails1.conf"
    # @example User app owned by Dan
    #   app_config_path(env: :usr, owner: 'dan', name: 'fillsim')
    #   #=> "/var/lib/ondemand-nginx/config/apps/usr/dan/fillsim.conf"
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
    #   #=> "~bob/ondemand/dev/rails1"
    # @example App root for user app owned by Dan
    #   app_root(env: :usr, owner: 'dan', name: 'fillsim')
    #   #=> "/var/www/ood/apps/usr/dan/gateway/fillsim"
    # @param env [Symbol] environment the app is run under
    # @param owner [String] the owner of the app
    # @param name [String] the name of the app
    # @return [String] the path to the app root on the local filesystem
    # @raise [InvalidRequest] if the environment specified doesn't exist
    def app_root(env:, owner:, name:)
      File.expand_path(
        @app_root.fetch(env) do
          raise InvalidRequest, "invalid request environment: #{env}"
        end % {env: env, owner: owner, name: name, portal: portal}
      )
    end

    attr_writer :app_root

    # The root directory of all the apps of a given type (usr, dev, sys)
    # is the parent directory of one of those apps.
    #
    # @return [String, nil] path to the root directory for the app type, and
    #   nil if app type undefined
    def apps_root(env:, owner:)
      Pathname.new(app_root(env: env, owner: owner, name: "app")).parent.to_s
    rescue InvalidRequest
      nil
    end

    # The URI used to access the app from the browser, not including any base-uri
    # @example URI for dev app owned by Bob
    #   app_request_uri(env: :dev, owner: 'bob', name: 'rails1')
    #   #=> "/dev/rails1"
    # @example URI for user app owned by Dan
    #   app_request_uri(env: :dev, owner: 'dan', name: 'fillsim')
    #   #=> "/usr/dan/fillsim"
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

    # Token used to identify a given app from the other apps
    # @example app token for dev app owned by Bob
    #   app_token(env: :dev, owner: 'bob', name: 'rails1')
    #   #=> "dev/bob/rails1"
    # @example app token for user app owned by Dan
    #   app_request_uri(env: :dev, owner: 'dan', name: 'fillsim')
    #   #=> "usr/dan/fillsim"
    # @param env [Symbol] environment the app is run under
    # @param owner [String] the owner of the app
    # @param name [String] the name of the app
    # @return [String] the token identifying the app
    # @raise [InvalidRequest] if the environment specified doesn't exist
    def app_token(env:, owner:, name:)
      @app_token.fetch(env) do
        raise InvalidRequest, "invalid request environment: #{env}"
      end % {env: env, owner: owner, name: name}
    end

    attr_writer :app_token

    # The passenger environment used for the given app environment
    # @example Dev app owned by Bob
    #   app_passenger_env(env: :dev, owner: 'bob', name: 'rails1')
    #   #=> "development"
    # @example User app owned by Dan
    #   app_passenger_env(env: :usr, owner: 'dan', name: 'fillsim')
    #   #=> "production"
    # @param env [Symbol] environment the app is run under
    # @param owner [String] the owner of the app
    # @param name [String] the name of the app
    # @return [String] the passenger environment to run app with in PUN
    def app_passenger_env(env:, owner:, name:)
      @app_passenger_env.fetch(env, "production")
    end

    attr_writer :app_passenger_env

    #
    # Validation configuration options
    #

    # Regular expression used to validate a given user name
    # @return [Regexp] user name regular expression
    def user_regex
      /\A#{@user_regex}\z/
    end

    attr_writer :user_regex

    # Minimum user id required to run the per-user NGINX as this user. This
    # restricts running processes as special users (i.e., 'root')
    # @return [Integer] minimum user id required to run as user
    attr_accessor :min_uid

    # Restrict starting up per-user NGINX process as user with this shell.
    # NB: This only affects the <tt>pun</tt> command, you are still able to
    #     start or stop the PUN using other commands (e.g., <tt>nginx</tt>,
    #     <tt>nginx_clean</tt>, ...)
    # @return [String] user shell that is blocked
    attr_accessor :disabled_shell

    # Define an error message that is displayed to users when they have a 
    #     disabled_shell.
    # @return [String] Error message
    attr_accessor :disabled_shell_message

    # Hide the stderr "Run 'nginx_stage --help' to see a full list of available 
    #     command line options." message when calling nginx_stage
    # @return [Boolean]
    attr_accessor :show_nginx_stage_help_message

    # Set BUNDLE_USER_CONFIG to /dev/null in the PUN environment
    # NB: This prevents a user's ~/.bundle/config from affecting OnDemand applications
    # @return [Boolean] set BUNDLE_USER_CONFIG to /dev/null in PUN environment
    attr_accessor :disable_bundle_user_config

    # Path to the root directory for custom html files
    # that NGINX can serve. Currently only the missing_home_directory.html
    # error page can be customized with this mechanism.
    #
    # @return [String] path to the custom html root
    attr_accessor :pun_custom_html_root

    #
    # Configuration module
    #

    # Default configuration file
    # @return [String] path to default yaml configuration file
    def default_config_path
      config = config_file
      unless File.file?(config)
        config = File.join root, 'config', 'nginx_stage.yml'
        warn "[DEPRECATION] The file '#{config}' is being deprecated. Please move this file to '#{config_file}'." if File.file?(config)
      end
      config
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
      self.ondemand_version_path = "/opt/ood/VERSION"
      self.ondemand_portal       = nil
      self.ondemand_title        = nil
      self.template_root         = "#{root}/templates"

      if debian?
        self.proxy_user = 'www-data'
      else
        self.proxy_user = 'apache'
      end

      self.nginx_bin        = '/opt/ood/ondemand/root/usr/sbin/nginx'
      self.nginx_signals    = %i(stop quit reopen reload)
      self.mime_types_path  = '/opt/ood/ondemand/root/etc/nginx/mime.types'

      self.passenger_root = '/opt/ood/ondemand/root/usr/share/ruby/vendor_ruby/phusion_passenger/locations.ini'

      self.passenger_ruby   = "#{root}/bin/ruby"
      self.passenger_nodejs = "#{root}/bin/node"
      self.passenger_python = "#{root}/bin/python"

      self.passenger_pool_idle_time = 300
      self.passenger_log_file = nil
      self.passenger_disable_anonymous_telemetry = 'on'
      self.passenger_options = {}

      self.pun_custom_env      = {}
      self.pun_custom_env_declarations = []
      self.pun_custom_html_root = '/etc/ood/config/pun/html'
      self.pun_config_path     = '/var/lib/ondemand-nginx/config/puns/%{user}.conf'
      self.pun_secret_key_base_path = '/var/lib/ondemand-nginx/config/puns/%{user}.secret_key_base.txt'

      self.pun_tmp_root        = '/var/tmp/ondemand-nginx/%{user}'
      self.pun_access_log_path = '/var/log/ondemand-nginx/%{user}/access.log'
      self.pun_error_log_path  = '/var/log/ondemand-nginx/%{user}/error.log'
      self.pun_log_format      = '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" "$http_x_forwarded_for"'
      self.pun_pid_path        = '/var/run/ondemand-nginx/%{user}/passenger.pid'
      self.pun_socket_path     = '/var/run/ondemand-nginx/%{user}/passenger.sock'
      self.pun_sendfile_root   = '/'
      self.pun_sendfile_uri    = '/sendfile'
      self.pun_app_configs     = [
        {env: :dev, owner: '%{user}', name: '*'},
        {env: :usr, owner: '*',       name: '*'},
        {env: :sys, owner: '',        name: '*'}
      ]

      self.app_config_path   = {
        dev: '/var/lib/ondemand-nginx/config/apps/dev/%{owner}/%{name}.conf',
        usr: '/var/lib/ondemand-nginx/config/apps/usr/%{owner}/%{name}.conf',
        sys: '/var/lib/ondemand-nginx/config/apps/sys/%{name}.conf'
      }
      self.app_root          = {
        dev: '/var/www/ood/apps/dev/%{owner}/gateway/%{name}',
        usr: '/var/www/ood/apps/usr/%{owner}/gateway/%{name}',
        sys: '/var/www/ood/apps/sys/%{name}'
      }
      self.app_request_uri   = {
        dev: '/dev/%{name}',
        usr: '/usr/%{owner}/%{name}',
        sys: '/sys/%{name}'
      }
      self.app_request_regex = {
        dev: '^/dev/(?<name>[-\w.]+)',
        usr: '^/usr/(?<owner>[\w]+)/(?<name>[-\w.]+)',
        sys: '^/sys/(?<name>[-\w.]+)'
      }
      self.app_token = {
        dev: 'dev/%{owner}/%{name}',
        usr: 'usr/%{owner}/%{name}',
        sys: 'sys/%{name}'
      }
      self.app_passenger_env = {
        dev: 'development',
        usr: 'production',
        sys: 'production'
      }

      self.user_regex     = '[\w@\.\-]+'
      self.min_uid        = 1000
      self.disabled_shell = '/access/denied'
      self.disabled_shell_message = 'user has a disabled shell: %s'
      self.show_nginx_stage_help_message = true

      self.disable_bundle_user_config = true
      self.nginx_file_upload_max = '10737420000'

      read_configuration(default_config_path) if File.file?(default_config_path)
    end

    # Read in a configuration from a file
    # @param file [String] path to the yaml configuration file
    # @return [void]
    def read_configuration(file)
      config_hash = symbolize(YAML.load_file(file)) || {}
      config_hash.each do |k,v|
        if instance_variable_defined? "@#{k}"
          self.send("#{k}=", v)
        else
          $stderr.puts %{Warning: invalid configuration option "#{k}"}
        end
      end
    end

    def debian?
      env = Dotenv.parse('/etc/os-release')
      return true if (env['ID'] =~ /(ubuntu|debian)/ or env['ID_LIKE'] == 'debian')
      false
    end

    private
      # Recursively symbolize keys in hash
      def symbolize(obj)
        return obj.each_with_object({}) {|(k, v), h| h[k.to_sym] =  symbolize(v)} if obj.is_a? Hash
        return obj.each_with_object([]) {|v, a|      a           << symbolize(v)} if obj.is_a? Array
        return obj
      end

      # Expand paths only if they are not special
      def expand_nginx_log_path(path)
        if path == "stderr" || path.start_with?("syslog:") || path.start_with?("memory:")
          path
        else
          File.expand_path path
        end
      end
  end
end
