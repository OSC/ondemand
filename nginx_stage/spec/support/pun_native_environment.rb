# frozen_string_literal: true

require 'socket'
require_relative 'pun_owned_processes'

# Capability skips are explicit; required native CI converts them to failures.
module PunNativeEnvironment
  include PunOwnedProcesses

  def require_native_signaling!
    NginxStage::PunProcess.check_signal_support!
  rescue NginxStage::Error, SystemCallError, IOError => e
    native_requirement!(false, "descriptor signaling unavailable: #{e.message}")
  end

  def require_native_nginx!
    binary = ENV['OOD_TEST_NGINX_BIN']
    return native_requirement!(false, 'set OOD_TEST_NGINX_BIN to run real nginx integration') unless binary

    unless binary.start_with?('/') && File.executable?(binary)
      raise ArgumentError, 'OOD_TEST_NGINX_BIN must be an absolute executable path'
    end

    require_native_signaling!
    binary
  end

  def require_native_sockets!(directory)
    native_requirement!(defined?(UNIXServer), 'requires Unix domain sockets')
    path = File.join(directory, 'capability.sock')
    server = UNIXServer.new(path)
    server.close
    File.unlink(path)
  rescue Errno::EPERM, Errno::EACCES, Errno::EAFNOSUPPORT => e
    native_requirement!(false, "Unix socket binding unavailable: #{e.class}")
  ensure
    server&.close unless server&.closed?
  end
end
