module NginxStage
  # This generator generates/controls the per-user NGINX process.
  class NginxProcessGenerator < BaseGenerator
    # The signal to send to the per-user NGINX process
    # @return [String] nginx signal
    attr_reader :signal

    # @param opts [Hash] various options for controlling the behavior of the generator
    # @option opts [String] :user (nil) the user of the per-user nginx
    # @option opts [String] :signal (nil) the signal to send nginx
    # @see BaseGenerator#initialize
    def initialize(opts)
      super(opts)
      @signal = opts.fetch(:signal, nil)
    end

    # Run the per-user NGINX process through `exec` (so we capture return code)
    # or return the command as a string
    add_hook :execute_or_return_nginx_cmd do
      exec_nginx(pun_config_path, signal, skip_nginx)
    end
  end
end
