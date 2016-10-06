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

    # URI used to access filesystem from the browser
    # @return [String] the filesystem URI
    def download_uri
      "#{sub_uri}#{NginxStage.pun_download_uri}" if NginxStage.pun_download_uri
    end

    # Path to the filesystem root where files are served from
    # @return [String] path to filesystem root
    def download_root
      NginxStage.pun_download_root(user: user)
    end

    # Array of wildcard paths to app configs user has access to
    # @return [Array<String>] list of wildcard app config paths
    def app_configs
      NginxStage.pun_app_configs(user: user).map do |envmt|
        NginxStage.app_config_path envmt
      end
    end
  end
end
