module NginxStage
  # This generator stages and generates the per-user NGINX environment.
  class PunConfigGenerator < Generator
    desc 'Generate a new per-user nginx config and process'

    footer <<-EOF.gsub(/^ {4}/, '')
    Examples:
        To generate a per-user nginx environment & launch nginx:

            nginx_stage pun --user=bob --app-init-uri='/nginx/init?redir=$http_x_forwarded_escaped_uri'

        this will add a URI redirect if the user accesses an app that doesn't exist.

        To generate ONLY the per-user nginx environment:

            nginx_stage pun --user=bob --skip-nginx

        this will return the per-user nginx config path and won't run nginx. In addition
        it will remove the URI redirect from the config unless we specify `--app-init-uri`.
    EOF

    # @!method user
    #   The user that the per-user NGINX will run as
    #   @return [User] the user of the nginx process
    #   @raise [MissingOption] if user isn't supplied
    add_option :user,
      opt_args: ["-u", "--user=USER", "# The USER of the per-user nginx process"],
      required: true do |user|
        User.new user
      end

    # @!method skip_nginx
    #   Whether we skip calling the NGINX process
    #   @return [Boolean] if true, skip calling the nginx binary
    add_option :skip_nginx,
      opt_args: ["-N", "--[no-]skip-nginx", "# Skip execution of the per-user nginx process", "# Default: false"],
      default: false

    # @!method app_init_uri
    #   The app initialization URI the user is redirected to if can't find the
    #   app in the per-user NGINX config
    #   @return [String] app init redirect url
    add_option :app_init_uri,
      opt_args: ["-a", "--app-init-uri=APP_INIT_URI", "# The user is redirected to the APP_INIT_URI if app doesn't exist"],
      default: nil

    # Validate that the user isn't a special user (i.e., `root`)
    add_hook :validate_user_not_special do
      min_uid = NginxStage.min_uid
      if user.uid < min_uid
        raise InvalidUser, "user is special: #{user} (#{user.uid} < #{min_uid})"
      end
    end

    # Create the user's personal per-user NGINX `/tmp` location for the various
    # nginx cache directories
    add_hook :create_user_tmp_root do
      empty_directory tmp_root
    end

    # Create the user's personal per-user NGINX `/log` location for the various
    # nginx log files (e.g., 'error.log' & 'access.log')
    add_hook :create_user_log_roots do
      empty_directory File.dirname(error_log_path)
      empty_directory File.dirname(access_log_path)
    end

    # Create per-user NGINX pid root
    add_hook :create_pid_root do
      empty_directory File.dirname(pid_path)
    end

    # Create and secure the nginx socket root. The socket file needs to be only
    # accessible by the reverse proxy user.
    add_hook :create_and_secure_socket_root do
      socket_root = File.dirname(socket_path)
      empty_directory socket_root
      FileUtils.chmod 0700, socket_root
      FileUtils.chown NginxStage.proxy_user, nil, socket_root if Process.uid == 0
    end

    # Generate the per-user NGINX config from the 'pun.conf.erb' template
    add_hook :create_config do
      template "pun.conf.erb", pun_config_path
    end

    # Run the per-user NGINX process through `exec` (so we capture return code)
    add_hook :exec_nginx do
      exec(NginxStage.nginx_cmd(user: user)) unless skip_nginx
    end

    # If skip nginx, then return path to the generated per-user NGINX config
    add_hook :return_pun_config_path do
      pun_config_path
    end


    private
      # per-user NGINX config path
      def pun_config_path
        NginxStage.pun_config_path(user: user)
      end

      # Primary group of the user
      def group
        user.group
      end

      # Path to the user's personal error.log
      def error_log_path
        NginxStage.error_log_path(user: user)
      end

      # Path to the user's personal access.log
      def access_log_path
        NginxStage.access_log_path(user: user)
      end

      # Path to user's personal tmp root
      def tmp_root
        NginxStage.tmp_root(user: user)
      end

      # Path to the user's per-user NGINX pid file
      def pid_path
        NginxStage.pid_path(user: user)
      end

      # Path to the user's per-user NGINX socket file
      def socket_path
        NginxStage.socket_path(user: user)
      end

      # Wildcard path to user's dev apps
      def app_dev_configs
        NginxStage.app_config_path(env: :dev, owner: user, name: '*')
      end

      # Wildcard path to ALL shared apps
      def app_shared_configs
        NginxStage.app_config_path(env: :shared, owner: '*', name: '*')
      end
  end
end
