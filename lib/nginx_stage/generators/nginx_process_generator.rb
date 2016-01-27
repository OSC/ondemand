module NginxStage
  # This generator generates/controls the per-user NGINX process.
  class NginxProcessGenerator < Generator
    # @!method user
    #   The user that the per-user NGINX will run as
    #   @return [User] the user of the nginx process
    #   @raise [MissingOption] if user isn't supplied
    add_option :user do
      raise MissingOption, "missing option: --user=USER"
    end

    # @!method skip_nginx
    #   Whether we skip calling the NGINX process
    #   @return [Boolean] if true, skip calling the nginx binary
    add_option :skip_nginx, false

    # @!method signale
    #   The signal to send to the per-user NGINX process
    #   @return [String] nginx signal
    add_option :signal, nil

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
