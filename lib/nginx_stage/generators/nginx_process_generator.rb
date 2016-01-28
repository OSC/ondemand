module NginxStage
  # This generator generates/controls the per-user NGINX process.
  class NginxProcessGenerator < Generator
    desc 'Generate/control a per-user nginx process'

    footer <<-EOF.gsub(/^ {4}/, '')
    Examples:
        To stop Bob's nginx process:

            nginx_stage nginx --user=bob --signal=stop

        which sends a `stop` signal to Bob's per-user NGINX process.

        If `--skip-nginx` is supplied it returns the system-level command
        that would have been called.
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

    # @!method signal
    #   The signal to send to the per-user NGINX process
    #   @return [String] nginx signal
    add_option :signal,
      opt_args: -> { ["-s", "--signal=SIGNAL", NginxStage.nginx_signals, "# Send SIGNAL to per-user nginx process: #{NginxStage.nginx_signals.join('/')}"] },
      default: nil

    # @!method skip_nginx
    #   Whether we skip calling the NGINX process
    #   @return [Boolean] if true, skip calling the nginx binary
    add_option :skip_nginx,
      opt_args: ["-N", "--[no-]skip-nginx", "# Skip execution of the per-user nginx process", "# Default: false"],
      default: false

    # Validate that the user isn't a special user (i.e., `root`)
    add_hook :validate_user_not_special do
      min_uid = NginxStage.min_uid
      if user.uid < min_uid
        raise InvalidUser, "user is special: #{user} (#{user.uid} < #{min_uid})"
      end
    end

    # Run the per-user NGINX process through `exec` (so we capture return code)
    add_hook :exec_nginx do
      exec(nginx_cmd) unless skip_nginx
    end

    # If skip nginx, then return nginx command
    add_hook :return_nginx_cmd do
      nginx_cmd
    end

    private
      # NGINX command
      def nginx_cmd
        NginxStage.nginx_cmd(user: user, signal: signal)
      end
  end
end
