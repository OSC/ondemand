# frozen_string_literal: true

require 'pathname'

module NginxStage
  # A class describing a Unix domain socket
  class SocketFile
    # @param socket [String] path to unix domain socket file
    # @raise [MissingSocketFile] if socket file doesn't exist in file system
    # @raise [InvalidSocketFile] if supplied file isn't a valid socket file
    def initialize(socket)
      @socket = Pathname.new(socket)
      raise MissingSocketFile, "missing socket file: #{socket}" unless File.exist?(socket)
      raise InvalidSocketFile, "invalid socket file: #{socket}" unless File.socket?(socket)
    end

    # Convert object to string
    # @return [String] path to socket file
    def to_s
      @socket.to_s
    end

    # Path to Unix domain socket file
    # @return [String] path to unix domain socket file
    def socket
      @socket.to_s
    end

    # Delete the socket from the file system
    def delete
      @socket.delete
    rescue StandardError
      warn "Unable to delete socket file at #{socket}"
    end
  end
end
