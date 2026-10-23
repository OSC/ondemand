# frozen_string_literal: true

module NginxStage
  # This generator cleans all running per-user NGINX processes that are
  # inactive (i.e., not active connections).
  class NginxCleanGenerator < Generator
    include NginxStage::SessionFinder

    desc 'Clean all user running PUNs with no active connections'

    footer <<-HELP.gsub(/^ {4}/, '')
    Examples:
        To clean up any running per-user nginx process with no active
        connections:

            nginx_stage nginx_clean

        this lists selected users; inspect diagnostics for cleanup errors.

        To clean up running per-user nginx processes regardless of active
        connections, subject to the safety checks below:

            nginx_stage nginx_clean --force

        this also lists selected users; inspect diagnostics for cleanup errors.

        To clean up one user regardless of active connections, subject to
        the same safety checks:

            nginx_stage nginx_clean --force --user exampleuser

        this also lists selected users; inspect diagnostics for cleanup errors.

        To ONLY display the users with inactive PUNs:

            nginx_stage nginx_clean --skip-nginx

        this won't terminate their per-user nginx process, probe sockets,
        remove files, or create/acquire lifecycle locks.

        Cleanup skips a busy lifecycle lock with a warning and continues with
        later users. Once acquired, it holds the lock through shutdown and cleanup.
        Successful signaling waits up to 30 seconds for both the socket and
        PID paths to disappear. --force ignores connection counts; it does
        not bypass PID validation or stale-state safety checks.

        For dead or invalid PID state, refused stale sockets can be recovered.
        Listening sockets, symlinks, and inconclusive probes are preserved.
        Disabled-user cleanup is
        discovered from PID/socket paths and .cleanup_pending retry records beside
        PUN configs; old configs, secrets, and empty runtime directories alone
        are not cleanup candidates. Partial failures keep the retry record.
        If an account becomes resolvable again, cleanup cancels its safe retry
        record under the lifecycle lock and preserves its remaining PUN state.

        Existing passwd records with failed full user/group lookup are preserved.
        Check lookup health: a complete directory-service outage can still be
        mistaken for deletion.
        Resolve uncertain process ownership before repairing PID/socket paths.
    HELP

    # Whether we forcefully kill all PUNs even if they have connections
    add_option :force do
      {
        opt_args: ['-f', '--[no-]force', '# Ignore active connections; retain safety checks', '# Default: false'],
        default:  false
      }
    end

    add_option :user do
      {
        opt_args: ['-u', '--user=USER', '# Operate on specific user', '# Default: nil (all users)'],
        default:  nil
      }
    end

    # Accepts `skip_nginx` as an option
    add_skip_nginx_support

    # Find users with PUNs that have no active sessions and kill the process
    add_hook :delete_puns_of_users_with_no_sessions do
      NginxStage.active_users(include_sockets: true).each do |u|
        next if user && user != u.to_s

        with_cleanup_lock(user: u) do
          begin
            pid_path = PidFile.new NginxStage.pun_pid_path(user: u)
          rescue MissingPidFile, Errno::ENOENT
            # Enumeration precedes lock acquisition; shutdown may have finished.
            cleanup_socket_without_pid(user: u)
            next
          rescue InvalidPidFile => e
            cleanup_invalid_pid(user: u, error: e)
            next
          end
          socket_path = NginxStage.pun_socket_path(user: u)
          identity = PunProcess.state(pid_file: pid_path, user: u)
          if [:dead, :foreign].include?(identity)
            cleanup_stale_pid(user: u, pid_path: pid_path, socket_path: socket_path)
            next
          end
          if identity == :unknown
            warn "Skipping cleanup for #{u}: PUN process identity is uncertain"
            next
          end

          begin
            SocketFile.new(socket_path)
          rescue MissingSocketFile
            # A live master may already have unlinked its socket while draining.
            warn "Skipping cleanup for #{u}: verified PUN master is alive without its socket (possibly draining)"
            next
          end
          if force || session_count(u).zero?
            puts u
            run_nginx(user: u, signal: :stop) unless skip_nginx
          end
        end
      rescue StandardError => e
        warn "Error trying to clean up active user #{u}: #{e.message}"
      end

      cleanup_users = NginxStage.inactive_users | NginxStage.pending_cleanup_users
      cleanup_users.each do |u|
        next if user && user != u.to_s

        if skip_nginx
          puts "#{u} (disabled)" if disabled_user?(u)
          next
        end

        with_cleanup_lock(user: u) do
          # Recheck restored accounts as well as disabled cleanup candidates.
          unless disabled_user?(u)
            cancel_pending_cleanup(user: u)
            next
          end

          puts "#{u} (disabled)"
          record_pending_cleanup(user: u)
          next unless stop_disabled_pun(user: u)

          remove_if_present(NginxStage.pun_secret_key_base_path(user: u))
          remove_if_present(NginxStage.pun_config_path(user: u))
          remove_if_present(NginxStage.pun_cleanup_path(user: u)) if cleanup_disabled_pid_root(user: u)
        end
      rescue StandardError => e
        warn "Error trying to clean up disabled user #{u}: #{e.message}"
      end
    end

    private

    # Cleanup must not queue all later users behind a busy lifecycle operation.
    # Dry runs inspect a snapshot and never create or acquire lifecycle locks.
    def with_cleanup_lock(user:, &block)
      return block.call if skip_nginx

      with_pun_lifecycle_lock(user: user, nonblock: true, &block)
    end

    # Socket-only crashes must remain discoverable without inventing a PID.
    # Use the normal conservative probe and leave configuration and secrets alone.
    def cleanup_socket_without_pid(user:)
      if path_occupied?(NginxStage.pun_pid_path(user: user))
        warn "Skipping cleanup for #{user}: PID path is still occupied (possibly a dangling symlink)"
        return
      end
      return unless path_occupied?(NginxStage.pun_socket_path(user: user))

      if skip_nginx
        puts user
      elsif SocketProbe.new(NginxStage.pun_socket_path(user: user)).remove_stale
        warn "stale socket file removed for #{user} (PID file is missing)"
      else
        warn "Skipping cleanup for #{user}: PID is missing but socket path is live or uncertain"
      end
    end

    # Create before shutdown can unlink the PID. Never follow a preexisting link
    # or accept another user's writable file as authorization for a retry.
    def record_pending_cleanup(user:)
      path = NginxStage.pun_cleanup_path(user: user)
      File.open(path, File::WRONLY | File::CREAT | File::EXCL, 0o600, &:flush)
    rescue Errno::EEXIST
      validate_pending_cleanup(path)
    end

    # A restored account no longer authorizes a pending disabled-user cleanup.
    # Do not recreate a record that disappeared after enumeration.
    def cancel_pending_cleanup(user:)
      path = NginxStage.pun_cleanup_path(user: user)
      validate_pending_cleanup(path)
      remove_if_present(path)
    rescue Errno::ENOENT
      false
    end

    def validate_pending_cleanup(path)
      stat = File.lstat(path)
      return if stat.file? && stat.uid == Process.euid && (stat.mode & 0o022).zero?

      raise Error, "Unsafe pending cleanup record: #{path}"
    end

    # Keep directory removal inside the same lifecycle lock as shutdown and
    # metadata removal. A per-user lock cannot protect a shared PID directory.
    def cleanup_disabled_pid_root(user:)
      dir = Pathname.new(NginxStage.pun_pid_path(user: user)).parent
      return true if dir.to_s == File.dirname(NginxStage.pun_pid_path(user: '*'))

      remove_pid_directory(dir)
    end

    # Retry a nonempty directory once while the caller still holds the lock.
    def remove_pid_directory(dir)
      begin
        FileUtils.rmdir(dir)
      rescue Errno::ENOTEMPTY
        sleep(0.5)
        FileUtils.rmdir(dir)
      end
      true
    rescue Errno::ENOENT
      # A previous attempt may already have removed the runtime directory.
      true
    rescue StandardError => e
      warn "Error trying to clean up the PID file directory '#{dir}' of disabled user: #{e.message}"
      false
    end

    # Recheck account state after acquiring the lifecycle lock.
    def disabled_user?(user)
      User.new(user)
      false
    rescue ArgumentError
      # A missing primary group must not authorize disabled-user cleanup.
      return true unless passwd_record_exists?(user)

      raise Error, "Account #{user} still exists but full user lookup failed; preserving PUN state"
    end

    # Match User's numeric-UID lookup before falling back to a literal name.
    # A complete NSS outage remains indistinguishable from account deletion.
    def passwd_record_exists?(user)
      if /\A\d+\z/.match?(user.to_s)
        begin
          Etc.getpwuid(user.to_s.to_i)
          return true
        rescue ArgumentError
          # The literal numeric account name may still resolve below.
        end
      end
      Etc.getpwnam(user.to_s)
      true
    rescue ArgumentError
      false
    end

    # A prior shutdown may already have removed the PID, leaving only metadata.
    # Preserve occupied PID/socket paths whose owner cannot be established.
    def stop_disabled_pun(user:)
      pid_path = PidFile.new(NginxStage.pun_pid_path(user: user))
      terminate_disabled_pun(user: user, pid_path: pid_path)
    rescue MissingPidFile, Errno::ENOENT
      if !path_occupied?(NginxStage.pun_pid_path(user: user)) &&
         SocketProbe.new(NginxStage.pun_socket_path(user: user)).remove_stale
        return true
      end

      warn "Skipping disabled user #{user}: PID or socket path still exists"
      false
    end

    # Disabled users cannot be resolved by nginx -s stop. Wait for both paths
    # after SIGTERM, or remove a dead PID only when no socket remains.
    def terminate_disabled_pun(user:, pid_path:)
      identity = PunProcess.state(pid_file: pid_path, user: user)
      raise Errno::ESRCH if [:dead, :foreign].include?(identity)

      PunProcess.signal(pid_file: pid_path, user: user, signal: :stop)
      wait_for_pun_shutdown(user: user)
      true
    rescue Errno::ESRCH
      unless SocketProbe.new(NginxStage.pun_socket_path(user: user)).remove_stale
        warn "Skipping disabled user #{user}: PID is gone but socket path still exists"
        return false
      end
      remove_if_present(pid_path)
      true
    rescue Errno::EPERM => e
      warn "Cannot terminate disabled user #{user}: #{e.message}"
      false
    end

    # A dead recorded PID can coexist with live orphaned workers. Remove the
    # socket only after a refused connection and an unchanged socket identity.
    def cleanup_stale_pid(user:, pid_path:, socket_path:)
      if skip_nginx
        puts user
        return
      end
      probe = SocketProbe.new(socket_path)
      if ![:absent, :stale].include?(probe.state)
        warn "Skipping cleanup for #{user}: PID is gone but socket path still exists"
      elsif probe.remove_stale && remove_if_present(pid_path)
        warn "stale pid file removed: #{pid_path}"
      end
    end

    def cleanup_invalid_pid(user:, error:)
      if skip_nginx
        warn "Skipping cleanup for #{user}: #{error.message}"
        return
      end
      path = NginxStage.pun_pid_path(user: user)
      probe = SocketProbe.new(NginxStage.pun_socket_path(user: user))
      if File.symlink?(path) || ![:absent, :stale].include?(probe.state)
        warn "Skipping cleanup for #{user}: #{error.message}; socket path still exists or PID is a symlink"
      elsif probe.remove_stale && remove_if_present(path)
        warn "Removed invalid PID file for #{user} (no live socket remains)"
      end
    end

    def remove_if_present(path)
      FileUtils.rm(path.to_s)
      true
    rescue Errno::ENOENT
      # A previous partial cleanup may already have removed this file.
      false
    end
  end
end
