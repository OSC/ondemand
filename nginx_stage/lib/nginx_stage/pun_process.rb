# frozen_string_literal: true

module NginxStage
  # Track one Linux process across PID reuse while checking its PUN identity.
  class PunProcess
    attr_reader :pid

    # Remember the process birth time before consulting its title or executable.
    def initialize(pid, config_path)
      @pid = pid
      @config_path = config_path
      @start_time = process_state&.last
    end

    # Startup also checks for a plausible draining master when its executable
    # cannot be verified. Signalling always uses the full check.
    def master?(verify_executable: true)
      title = File.read("/proc/#{pid}/cmdline").split("\0", 2).first.to_s
      title.start_with?('nginx: master process ') &&
        title.end_with?(" -c #{@config_path}") &&
        (!verify_executable || File.identical?("/proc/#{pid}/exe", NginxStage.nginx_bin)) && running?
    rescue SystemCallError
      false
    end

    # A reused PID or a zombie cannot perform any more nginx cleanup.
    def running?
      state, start_time = process_state
      !@start_time.nil? && start_time == @start_time && !['Z', 'X'].include?(state)
    end

    private

      # comm can contain spaces and parentheses; fields after its final ') '
      # begin with state (field 3), then starttime is field 22.
      def process_state
        fields = File.read("/proc/#{pid}/stat").rpartition(') ').last.split
        raise Error, "invalid process state for PID #{pid}" unless fields.size >= 20

        fields.values_at(0, 19)
      rescue Errno::ENOENT, Errno::ESRCH
        nil
      end
  end
end
