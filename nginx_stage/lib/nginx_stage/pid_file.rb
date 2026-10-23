# frozen_string_literal: true

require 'pathname'

module NginxStage
  # A class to handle a PID file
  class PidFile
    # Process id that describes this object
    # @return [Integer] the pid object was initialized with
    attr_reader :pid

    # Linux and macOS use a signed 32-bit pid_t for process IDs.
    MAX_PID = (2**31) - 1

    # Keep PID records within nginx's NGX_INT64_LEN + 2 byte buffer size.
    # Bound reads and reject oversized records before interpreting their contents.
    MAX_FILE_BYTES = 22

    # @param pid [Integer] the pid describing a process
    # @raise [MissingPidFile] if pid file doesn't exist in file system
    # @raise [InvalidPidFile] if it is an invalid pid file
    def initialize(pid_path)
      @pid_path = Pathname.new(pid_path)
      raise MissingPidFile, "missing PID file: #{pid_path}" unless @pid_path.exist?
      raise InvalidPidFile, "invalid PID file: #{pid_path}" unless @pid_path.file?

      # Read one extra byte to detect oversized files without reading all of them.
      contents = @pid_path.read(MAX_FILE_BYTES + 1).to_s
      raise InvalidPidFile, "invalid PID file: #{pid_path}" if contents.bytesize > MAX_FILE_BYTES

      contents = contents.strip
      # Require a positive decimal token, allowing leading zeros.
      raise InvalidPidFile, "invalid PID file: #{pid_path}" unless /\A0*[1-9][0-9]*\z/.match?(contents)

      @pid = Integer(contents, 10)
      raise InvalidPidFile, "invalid PID file: #{pid_path}" if @pid > MAX_PID
    end

    # Whether the corresponding pid is a running process
    # @return [Boolean] whether it is a running process
    def running_process?
      Process.getpgid @pid
      true
    rescue Errno::ESRCH
      false
    end

    # Convert object to string
    # @return [String] the pid path
    def to_s
      @pid_path.to_s
    end

    # Path of the PID file
    # @return [String] the path of the pid file
    def pid_path
      @pid_path.to_s
    end

    # Remove the file from the file system
    def delete
      @pid_path.delete
    rescue StandardError
      warn "Unable to delete pid file at #{pid_path}"
    end
  end
end
