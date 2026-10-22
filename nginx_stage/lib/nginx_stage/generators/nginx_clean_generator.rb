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
          with_pun_lifecycle_lock(user: u) do
            begin
              pid_path = PidFile.new NginxStage.pun_pid_path(user: u)
            rescue InvalidPidFile => e
              # Never unlink an existing socket based on an invalid PID.
              socket_path = NginxStage.pun_socket_path(user: u)
              if path_occupied?(socket_path)
                warn "Skipping cleanup for #{u}: #{e.message}; socket path still exists"
              elsif skip_nginx
                warn "Skipping cleanup for #{u}: #{e.message}"
              elsif remove_if_present(NginxStage.pun_pid_path(user: u))
                warn "Removed invalid PID file for #{u} (no socket path exists)"
              end
              next
            end
            socket = SocketFile.new NginxStage.pun_socket_path(user: u)
            sessions = session_count(u)
            cleanup_stale_files(pid_path, socket) if !skip_nginx && !pid_path.running_process?
            if sessions.zero? || force
              puts u
              unless skip_nginx
                o, s = run_nginx(user: u, signal: :stop)
                warn o unless s.success?
              end
            end
          end
        rescue StandardError => e
          warn "Error trying to clean up active user #{u}: #{e.message}"
        end
      end

      pid_parent_dirs_to_remove_later = []
      NginxStage.inactive_users.each do |u|
        begin
          next if user && user != u.to_s

          puts "#{u} (disabled)"
          next if skip_nginx

          with_pun_lifecycle_lock(user: u) do
            pid_path = PidFile.new NginxStage.pun_pid_path(user: u)

            # Disabled users cannot be resolved by nginx -s stop. Process.kill
            # avoids a shell and distinguishes nonexistent from forbidden PIDs.
            begin
              Process.kill('TERM', pid_path.pid)
              wait_for_pun_shutdown(user: u)
            rescue Errno::ESRCH
              # A missing PID does not prove a remaining socket is abandoned.
              socket_path = NginxStage.pun_socket_path(user: u)
              if path_occupied?(socket_path)
                warn "Skipping disabled user #{u}: PID is gone but socket path still exists"
                next
              end
              # No process remains to remove its stale PID file.
              remove_if_present(pid_path)
            rescue Errno::EPERM => e
              # Preserve secrets/configuration if the PUN may still be running.
              warn "Cannot terminate disabled user #{u}: #{e.message}"
              next
            end
            remove_if_present(NginxStage.pun_secret_key_base_path(user: u))
            remove_if_present(NginxStage.pun_config_path(user: u))
            pid_path_parent_dir = Pathname.new(pid_path.to_s).parent
            pid_parent_dirs_to_remove_later.push(pid_path_parent_dir)
          end
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
            sleep(0.5)
            # Then try again once.
            FileUtils.rmdir(dir)
          end
        rescue StandardError => e
          warn "Error trying to clean up the PID file directory '#{dir}' of disabled user: #{e.message}"
        end
      end
    end

    def cleanup_stale_files(pid_path, socket)
      pid_path.delete
      socket.delete

      $stderr.puts "stale pid file removed: #{pid_path.to_s}"
    end

    private

    def remove_if_present(path)
      FileUtils.rm(path.to_s)
    rescue Errno::ENOENT
      # A previous partial cleanup may already have removed this file.
      nil
    end
  end
end
