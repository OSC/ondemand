# frozen_string_literal: true

require 'json'
require 'time'

# Record the first failure before Rails attempts screenshots and browser reset.
module CiDebugEvents
  def self.emit(event, test)
    data = {
      event:             event,
      at:                Time.now.utc.iso8601(6),
      monotonic:         Process.clock_gettime(Process::CLOCK_MONOTONIC),
      pid:               Process.pid,
      test:              "#{test.class}##{test.name}",
      recorded_failures: test.failures.map { |failure| { type: failure.class.name, message: failure.message[0, 2000] } }
    }
    warn("CI_DEBUG #{JSON.generate(data)}")
  rescue StandardError
    # A logging failure must not replace a test or teardown exception.
    nil
  end

  def before_setup
    CiDebugEvents.emit('start', self)
    super
  end

  def before_teardown
    CiDebugEvents.emit('before_teardown', self)
    super
  end

  def after_teardown
    super
  ensure
    CiDebugEvents.emit('finish', self)
  end
end
