# frozen_string_literal: true

require 'timeout'

# Own every PID until it is reaped; never signal a PID after reaping it.
module PunOwnedProcesses
  def owned_children
    @owned_children ||= {}
  end

  def track_child(pid, *streams)
    owned_children[pid] = streams
    pid
  end

  def forget_child(pid)
    Array(owned_children.delete(pid)).each { |stream| stream.close unless stream.closed? }
  end

  def wait_until(seconds = 5)
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + seconds
    until yield
      if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
        raise Timeout::Error, 'native test condition did not complete'
      end

      sleep 0.01
    end
  end

  def await_child(pid)
    result = nil
    wait_until { result = Process.wait2(pid, Process::WNOHANG) }
    forget_child(pid)
    result.last
  end

  def child_running?(pid)
    return true unless Process.wait2(pid, Process::WNOHANG)

    forget_child(pid)
    false
  end

  def cleanup_children
    owned_children.each_key do |pid|
      # An unreaped child reserves its PID, even if it has already exited.
      result = Process.wait2(pid, Process::WNOHANG)
      unless result
        Process.kill('KILL', pid)
        await_child(pid)
      end
    rescue Errno::ESRCH, Errno::ECHILD
      nil
    ensure
      forget_child(pid)
    end
  end

  def native_requirement!(condition, reason)
    return if condition

    raise "Required native coverage unavailable: #{reason}" if ENV['OOD_REQUIRE_NATIVE_PUN_TESTS'] == '1'

    skip reason
  end
end
