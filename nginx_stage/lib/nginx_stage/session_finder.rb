# frozen_string_literal: true

require 'open3'

module NginxStage
  module SessionFinder
    def session_count(user)
      out, err, status = Open3.capture3('timeout', '10', 'ps', '-o', 'cmd', '-u', user.to_s)
      # ps exits 1 with no error when the user has no processes. Any other
      # failure (e.g. a timeout) must not look like a PUN with no sessions.
      unless status.success? || (status.exitstatus == 1 && err.empty?)
        raise Error, "unable to count sessions for #{user} (ps exit #{status.exitstatus}): #{err.strip}"
      end

      out.split("\n").select do |command|
        # matches 'Passenger NodeApp', 'Passenger RubyApp' and so on.
        command.match?(/Passenger \w+App:/)
      end.count
    end
  end
end
