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
            rescue MissingPidFile, Errno::ENOENT
              # Enumeration precedes lock acquisition; shutdown may have finished.
              next
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
            socket_path = NginxStage.pun_socket_path(user: u)
            unless pid_path.running_process?
              cleanup_stale_pid(user: u, pid_path: pid_path, socket_path: socket_path)
              next
            end

            begin
              SocketFile.new(socket_path)
            rescue MissingSocketFile
              # A live master may already have unlinked its socket while draining.
              next
            end
            sessions = session_count(u)
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
            # An account can reappear while this operation waits for the lock.
            next unless disabled_user?(u) && stop_disabled_pun(user: u)

            remove_if_present(NginxStage.pun_secret_key_base_path(user: u))
            remove_if_present(NginxStage.pun_config_path(user: u))
            pid_path_parent_dir = Pathname.new(NginxStage.pun_pid_path(user: u)).parent
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
        rescue Errno::ENOENT
          # Residual configuration may outlive the runtime directory.
          nil
        rescue StandardError => e
          warn "Error trying to clean up the PID file directory '#{dir}' of disabled user: #{e.message}"
        end
      end
    end

    private

    # Recheck account state after acquiring the lifecycle lock.
    def disabled_user?(user)
      User.new(user)
      false
    rescue ArgumentError
      true
    end

    # A prior shutdown may already have removed the PID, leaving only metadata.
    # Preserve occupied PID/socket paths whose owner cannot be established.
    def stop_disabled_pun(user:)
      pid_path = PidFile.new(NginxStage.pun_pid_path(user: user))
      terminate_disabled_pun(user: user, pid_path: pid_path)
    rescue MissingPidFile, Errno::ENOENT
      paths = [NginxStage.pun_pid_path(user: user), NginxStage.pun_socket_path(user: user)]
      return true unless paths.any? { |path| path_occupied?(path) }

      warn "Skipping disabled user #{user}: PID or socket path still exists"
      false
    end

    # Disabled users cannot be resolved by nginx -s stop. Wait for both paths
    # after SIGTERM, or remove a dead PID only when no socket remains.
    def terminate_disabled_pun(user:, pid_path:)
      Process.kill('TERM', pid_path.pid)
      wait_for_pun_shutdown(user: user)
      true
    rescue Errno::ESRCH
      if path_occupied?(NginxStage.pun_socket_path(user: user))
        warn "Skipping disabled user #{user}: PID is gone but socket path still exists"
        return false
      end
      remove_if_present(pid_path)
      true
    rescue Errno::EPERM => e
      warn "Cannot terminate disabled user #{user}: #{e.message}"
      false
    end

    # A dead recorded PID does not establish who owns a remaining socket.
    # Remove only a stale PID with no occupied socket path, and report real removal.
    def cleanup_stale_pid(user:, pid_path:, socket_path:)
      if path_occupied?(socket_path)
        warn "Skipping cleanup for #{user}: PID is gone but socket path still exists"
      elsif skip_nginx
        puts user
      elsif remove_if_present(pid_path)
        warn "stale pid file removed: #{pid_path}"
      end
    end

    def remove_if_present(path)
      FileUtils.rm(path.to_s)
    rescue Errno::ENOENT
      # A previous partial cleanup may already have removed this file.
      nil
    end
  end
end
