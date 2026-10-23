# frozen_string_literal: true

module NginxStage
  # This generator generates/controls the per-user NGINX process.
  class NginxProcessGenerator < Generator
    desc 'Generate/control a per-user nginx process'

    footer <<-HELP.gsub(/^ {4}/, '')
    Examples:
        To stop Bob's nginx process:

            nginx_stage nginx --user=bob --signal=stop

        which sends a `stop` signal to Bob's per-user NGINX process.

        After successful stop/quit signaling, wait up to 30 seconds for both
        the socket and PID paths to disappear. A timeout returns an error;
        it does not force shutdown. Startup stays blocked while the old
        master is alive, even if its socket has already disappeared.

        Retry startup after shutdown completes. To interrupt a verified
        draining PUN, an administrator can explicitly use --signal=stop.
        Signals reject unusable PID files, including files over 22 bytes.
        Never delete a PID or socket path merely to bypass a startup error.

        Signals use verified Linux process descriptors instead of nginx -s.
        If `--skip-nginx` is supplied it describes the requested signal or
        returns the startup command without executing it.
    HELP

    # Accepts `user` as an option and validates user
    add_user_support

    # Accepts `skip_nginx` as an option
    add_skip_nginx_support

    # @!method signal
    #   The signal to send to the per-user NGINX process
    #   @return [String] nginx signal
    add_option :signal do
      {
        opt_args: ['-s', '--signal=SIGNAL', NginxStage.nginx_signals,
                   "# Send SIGNAL to per-user nginx process: #{NginxStage.nginx_signals.join('/')}"],
        default:  nil
      }
    end

    # Run the per-user NGINX process (exit quietly on success)
    add_hook :exec_nginx do
      unless skip_nginx
        operation = proc do
          o, s = run_nginx(user: user, signal: signal)
          s.success? ? exit : abort(o)
        end

        # A missing signal starts nginx directly, so it must also be serialized.
        if signal.nil? || ['stop', 'quit'].include?(signal.to_s)
          with_pun_lifecycle_lock(user: user, &operation)
        else
          operation.call
        end
      end
    end

    # If skip nginx, then output nginx command
    add_hook :output_nginx_cmd do
      if signal
        puts "Requested process signal: #{signal} for #{user}; no signal sent"
      else
        puts "#{NginxStage.nginx_bin} #{NginxStage.nginx_args(user: user).join(' ')}"
      end
    end
  end
end
