# frozen_string_literal: true

require 'digest'

module BatchConnect
  # Store instances are short-lived; retain a bounded diagnostic history per process.
  class SessionStoreDiagnostics
    MAX_ENTRIES = 256
    REPEAT_INTERVAL = 300
    @failures = {}
    @mutex = Mutex.new

    def self.forget(path)
      @mutex.synchronize { @failures.delete(path.expand_path.to_s) }
    end

    def self.report(path, error, contents)
      key = path.expand_path.to_s
      signature = Digest::SHA256.new.update(error.class.name.to_s).update(error.message).update(contents.to_s).digest
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      @mutex.synchronize do
        previous = @failures[key]
        return if previous && previous.first == signature && now - previous.last < REPEAT_INTERVAL

        Rails.logger.error("ERROR: Error parsing file '#{path}' --- #{error.class} - #{error.message}")
        @failures.delete(key)
        @failures.shift if @failures.size >= MAX_ENTRIES
        @failures[key] = [signature, now]
      end
    end
  end
end
