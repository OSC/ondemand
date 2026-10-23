# frozen_string_literal: true

require 'socket'
require_relative 'pun_owned_processes'

# Capability skips are explicit; required native CI converts them to failures.
module PunNativeEnvironment
  include PunOwnedProcesses

  def require_native_signaling!
    native_requirement!(NginxStage::PunProcess.proc_available?, 'requires procfs in the caller PID namespace')
    supported = NginxStage::PunProcess::SUPPORTED_CPUS.include?(RbConfig::CONFIG['host_cpu'])
    native_requirement!(supported, 'requires a CPU supported by PUN descriptor signaling')
    File.open('/proc/self', File::RDONLY) do |handle|
      Kernel.syscall(NginxStage::PunProcess::SIGNAL_SYSCALL, handle.fileno, 0, 0, 0)
    end
  rescue Errno::ENOSYS, Errno::EPERM, Errno::EACCES, NotImplementedError => e
    native_requirement!(false, "descriptor signaling unavailable: #{e.class}")
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
