module NginxStage
  # This generator cleans all running per-user NGINX processes that are
  # inactive (i.e., not active connections).
  class NginxCleanGenerator < Generator
    desc 'Clean all user running PUNs with no active connections'

    footer <<-EOF.gsub(/^ {4}/, '')
    Examples:
        To clean up any running per-user nginx process with no active
        connections:

            nginx_stage nginx_clean

        this displays the users who had their PUNs shutdown.

        To clean up ALL running per-user nginx processes whether it has an
        active connection or not:

            nginx_stage nginx_clean --force

        this also displays the users who had their PUNs shutdown.

        To clean up ALL running per-user nginx processes belonging to a specific user
        whether it has an active connection or not:

            nginx_stage nginx_clean --force --user exampleuser

        this also displays the users who had their PUNs shutdown.

        To ONLY display the users with inactive PUNs:

            nginx_stage nginx_clean --skip-nginx

        this won't terminate their per-user nginx process.
    EOF

    # Whether we forcefully kill all PUNs even if they have connections
    add_option :force do
      {
        opt_args: ["-f", "--[no-]force", "# Force clean ALL per-user nginx processes", "# Default: false"],
        default: false
      }
    end

    add_option :user do
      {
        opt_args: ["-u", "--user", "# Operate on specific user", "# Default: nil (all users)"],
        default: nil,
      }
    end

    # Accepts `skip_nginx` as an option
    add_skip_nginx_support

    # Find users with PUNs that have no active sessions and kill the process
    add_hook :delete_puns_of_users_with_no_sessions do
      NginxStage.active_users.each do |u|
        begin
          next if (user && user != u)
          pid_path = PidFile.new NginxStage.pun_pid_path(user: u)
          socket = SocketFile.new NginxStage.pun_socket_path(user: u)
          cleanup_stale_files(pid_path, socket) unless pid_path.running_process? 
          if socket.sessions.zero? || force
            puts u
            if !skip_nginx
              o, s = Open3.capture2e(
                NginxStage.nginx_env(user: u),
                NginxStage.nginx_bin,
                *NginxStage.nginx_args(user: u, signal: :stop)
              )
              $stderr.puts o unless s.success?
            end
          end
        rescue
          $stderr.puts "#{$!.to_s}"
        end
      end
    end

    def cleanup_stale_files(pid_path, socket)
      pid_path.delete
      socket.delete

      $stderr.puts "stale pid file removed: #{pid_path.to_s}"
    end
  end
end
