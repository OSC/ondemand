module NginxStage
  # A view used as context for the pun config ERB template file
  module PunConfigView
    # Primary group of the user
    # @return [String] primary group of user
    def group
      user.group
    end

    # Path to the user's personal error.log
    # @return [String] path to error log
    def error_log_path
      NginxStage.pun_error_log_path(user: user)
    end

    # Path to the user's personal access.log
    # @return [String] path to access log
    def access_log_path
      NginxStage.pun_access_log_path(user: user)
    end

    # Log format for access.log
    # @return [String] log format configuration parameters
    def log_format
      NginxStage.pun_log_format
    end

    # Path to the user's per-user NGINX pid file
    # @return [String] path to pid file
    def pid_path
      NginxStage.pun_pid_path(user: user)
    end

    # Path to system-installed NGINX mime.types config file
    # @return [String] path to system-installed NGINX mime.types config
    def mime_types_path
      NginxStage.mime_types_path
    end

    # Path to system-installed Passenger locations.ini file
    # @return [String] path to Passenger locations.ini
    def passenger_root
      NginxStage.passenger_root
    end

    # Path to system-installed Ruby binary
    # @return [String] the system-installed Ruby binary
    def passenger_ruby
      NginxStage.passenger_ruby
    end

    # Path to system-installed NodeJS binary
    # @return [String] the system-installed NodeJS binary
    def passenger_nodejs
      NginxStage.passenger_nodejs
    end

    # Path to system-installed python binary
    # @return [String] the system-installed python binary
    def passenger_python
      NginxStage.passenger_python
    end

    # The maximum number of seconds that an application process may be idle.
    # @return [Integer] the value for passenger_pool_idle_time
    def passenger_pool_idle_time
      NginxStage.passenger_pool_idle_time
    end

    # The path to the Passenger log file for the user.
    # @return [String, nil] the path for passenger_log_file
    def passenger_log_file
      NginxStage.passenger_log_file(user: user)
    end

    # Hash of Passenger configuration options
    # @return [Hash] Hash of Passenger configuration options
    def passenger_options
      NginxStage.passenger_options
    end

    # Max file upload size in bytes (e.g., 10737420000)
    # @return [String] the max file size clients can upload
    def nginx_file_upload_max
      NginxStage.nginx_file_upload_max
    end

    # Path to user's personal tmp root
    # @return [String] path to tmp root
    def tmp_root
      NginxStage.pun_tmp_root(user: user)
    end

    # Path to the user's per-user NGINX socket file
    # @return [String] path to socket file
    def socket_path
      NginxStage.pun_socket_path(user: user)
    end

    # Internal URI used to access filesystem from apps
    # @return [String] the filesystem URI
    def sendfile_uri
      NginxStage.pun_sendfile_uri
    end

    # Path to the filesystem root where files are served from
    # @return [String] path to filesystem root
    def sendfile_root
      NginxStage.pun_sendfile_root(user: user)
    end

    # Array of wildcard paths to app configs user has access to
    # @return [Array<String>] list of wildcard app config paths
    def app_configs
      NginxStage.pun_app_configs(user: user).map do |envmt|
        NginxStage.app_config_path **envmt
      end
    end

    def missing_home_directory?
      ! Dir.exist?(user.dir)
    end

    def custom_html_root
      NginxStage.pun_custom_html_root
    end

    def default_html_root
      File.join NginxStage.root, "html"
    end

    # Array of env vars to declare in NGINX config using env directive
    # @return [Array<String>] list of env vars to declare in NGINX config
    def env_declarations
      NginxStage.clean_nginx_env(user: user).keys
    end

    def disable_bundle_user_config?
      NginxStage.disable_bundle_user_config
    end

    # View used to confirm whether the user wants to restart the PUN to reload
    # configuration changes
    # @return [String] restart confirmation view
    def restart_confirmation
      <<-EOF.gsub("'", %q{\\\'})
        <html>
        <head>
          <style>
            body {
              font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
              font-size: 16px;
              line-height: 1.4;
              color: #333;
              font-weight: 300;
              padding: 15px;
            }
            h2 {
              font-weight: 500;
              font-size: 30px;
            }
            .text-danger {
              color: #a94442;
            }
            .btn-danger {
              text-decoration: none;
              font-weight: 400;
              padding: 10px 16px;
              border-radius: 6px;
              color: #fff;
              background-color: #d9534f;
            }
          </style>
        </head>
        <body>
          <h2>
            App has not been initialized or does not exist
          </h2>
          <p class="text-danger">
            This is the first time this app has been launched in your per-user
            NGINX (PUN) server. This requires a configuration change followed
            by a restart of your PUN server. Be sure you save all the work you
            are doing in other apps that have active websocket connections
            (i.e., Shell App) and you complete all file uploads/downloads.
          </p>
          <p>
            Clicking the "Initialize App" button will apply the configuration
            change and restart your per-user NGINX (PUN) server.
          </p>
          <a href="#{app_init_url}" class="btn-danger">Initialize App</a>
        </body>
        </html>
      EOF
    end
  end
end
