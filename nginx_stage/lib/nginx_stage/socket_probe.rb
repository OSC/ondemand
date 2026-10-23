# frozen_string_literal: true

require 'socket'

module NginxStage
  # A single nonblocking connection distinguishes a refused Unix socket from a
  # listener. Backlog pressure and all inconclusive errors preserve the path.
  # Call and remove only while holding the PUN lifecycle lock in trusted roots.
  class SocketProbe
    attr_reader :state

    def initialize(path)
      @path = path.to_s
      @stat = File.lstat(@path)
      @state = @stat.socket? ? probe : :uncertain
    rescue Errno::ENOENT
      @state = :absent
    rescue SystemCallError, IOError
      @state = :uncertain
    end

    # Recheck identity before unlinking. The lifecycle lock excludes cooperating
    # startup/cleanup; the configured directory must exclude untrusted writers.
    def remove_stale
      return true if state == :absent && !File.exist?(@path) && !File.symlink?(@path)
      return false unless state == :stale

      current = File.lstat(@path)
      return false unless same_socket?(current)

      File.unlink(@path)
      true
    rescue Errno::ENOENT
      true
    end

    private

    def same_socket?(current)
      current.socket? && current.dev == @stat.dev && current.ino == @stat.ino
    end

    def probe
      socket = Socket.new(Socket::AF_UNIX, Socket::SOCK_STREAM, 0)
      result = socket.connect_nonblock(Socket.sockaddr_un(@path), exception: false)
      result.eql?(0) ? :listening : :uncertain
    rescue Errno::ECONNREFUSED
      :stale
    rescue SystemCallError, IOError
      :uncertain
    ensure
      socket&.close
    end
  end
end
