require 'pathname'

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
        NginxStage.app_config_path envmt
      end
    end

    def missing_home_directory?
      ! File.directory? user.dir
    end

    def fix_missing_home_directory
      custom_path = Pathname.new(NginxStage.config_root).join("nginx_missing_home_directory_error.html")

      if custom_path.file? && custom_path.readable?
        html = custom_path.read
      else
        # instead of embedded string, lets make this a FILE that is on the file system that we can read
        # oh thats escaping ' with the idea that we can embed it in a ' in nginx config and it will work
        html = <<-EOF
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
          </style>
        </head>
        <body>
          <h2>Home directory not found</h2>
          <p>
          Your home directory at %<home>s appears to be missing. If this is the first time you have logged in with this account, you may
          need to access our systems using SSH in order to trigger the creation of your home directory.
          </p>
          <ol>
            <li><a target="_blank" href="/pun/sys/shell/ssh/default">Open Shell to create home directory</a></li>
            <li><a href="%<restart>s">Restart Web Server</a></li>
        </body>
        </html>
        EOF
      end

      sprintf(html, :home => user.dir, :restart => "/nginx/stop?redir=/pun/sys/dashboard").gsub("'", %q{\\\'})
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
