module NginxStage
  # This generator cleans all running per-user NGINX processes that are
  # inactive (i.e., not active connections).
  class NginxCleanGenerator < Generator

    include NginxStage::SessionFinder

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
        opt_args: ["-u", "--user=USER", "# Operate on specific user", "# Default: nil (all users)"],
        default: nil,
      }
    end

    # Accepts `skip_nginx` as an option
    add_skip_nginx_support

    # Find users with PUNs that have no active sessions and kill the process
    add_hook :delete_puns_of_users_with_no_sessions do
      NginxStage.active_users.each do |u|
        begin
          next if (user && user != u.to_s)
          pid_path = PidFile.new NginxStage.pun_pid_path(user: u)
          socket = SocketFile.new NginxStage.pun_socket_path(user: u)
          sessions = session_count(u)
          cleanup_stale_files(pid_path, socket) unless pid_path.running_process?
          if sessions.zero? || force
            puts u
            if !skip_nginx
              NginxStage.clean_nginx_env(user: user)
              o, s = Open3.capture2e(
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

      pid_parent_dirs_to_remove_later = []
      NginxStage.inactive_users.each do |u|
        begin
          puts "#{u} (disabled)"
          pid_path = PidFile.new NginxStage.pun_pid_path(user: u)

          # Send a SIGTERM to the master nginx process to kill the PUN.
          # 'nginx stop' won't work, since getpwnam(3) will cause an error.
          `kill -s TERM #{pid_path.pid}`
          FileUtils.rm(NginxStage.pun_secret_key_base_path(user: u).to_s)
          FileUtils.rm(NginxStage.pun_config_path(user: u).to_s)
          pid_path_parent_dir = Pathname.new(pid_path.to_s).parent
          pid_parent_dirs_to_remove_later.push(pid_path_parent_dir)
        rescue StandardError => e
          warn "Error trying to clean up disabled user #{u}: #{e.message}"
        end
      end

      # Remove the PID path parent directories now that the nginx processes have
      # had time to clean up their Passenger PID file and socket.
      pid_parent_dirs_to_remove_later.each do |dir|
        begin
          begin
            FileUtils.rmdir(dir)
          rescue Errno::ENOTEMPTY
            # Wait for a short time, while Nginx cleans up its PID file.
            sleep(0.05)
            # Then try again once.
            FileUtils.rmdir(dir)
          end
        rescue StandardError => e
          warn "Error trying to clean up the PID file directory of disabled user #{u}: #{e.message}"
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
