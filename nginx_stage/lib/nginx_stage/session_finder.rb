# frozen_string_literal: true

require 'open3'

module NginxStage
  module SessionFinder
    def session_count(user)
      output, status = Open3.capture2('timeout', '10', 'ps', '-o', 'cmd', '-u', user.to_s)
      unless status.success?
        raise Error, "Unable to determine PUN sessions for #{user}: ps failed (status #{status.exitstatus})"
      end

      output.split("\n").select do |command|
        # matches 'Passenger NodeApp', 'Passenger RubyApp' and so on.
        command.match?(/Passenger \w+App:/)
      end.count
    end
  end
end
