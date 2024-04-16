# frozen_string_literal: true

module NginxStage
  module SessionFinder
    def session_count(user)
      `timeout 10 ps -o cmd -u #{user}`.split("\n").select do |command|
        command.match?(/Passenger \w+App:/)
      end.count
    end
  end
end
