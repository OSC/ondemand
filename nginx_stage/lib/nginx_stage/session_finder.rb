# frozen_string_literal: true

require 'open3'

module NginxStage
  # Count Passenger apps only after a conclusive process-listing result.
  module SessionFinder
    def session_count(user)
      output, error, status = Open3.capture3('timeout', '10', 'ps', '-o', 'cmd', '-u', user.to_s)
      # procps reports an empty selection as status 1 with only its header.
      # Neither arbitrary status-1 errors nor partial output establish inactivity.
      empty_selection = status.exitstatus == 1 && output.strip == 'CMD' && error.empty?
      unless status.success? || empty_selection
        raise Error, "Unable to determine PUN sessions for #{user}: ps failed (status #{status.exitstatus})"
      end

      output.split("\n").select do |command|
        # matches 'Passenger NodeApp', 'Passenger RubyApp' and so on.
        command.match?(/Passenger \w+App:/)
      end.count
    end
  end
end
