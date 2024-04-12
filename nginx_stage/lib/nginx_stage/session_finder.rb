module NginxStage
  module SessionFinder
    def session_count(user)
      `ps  -o cmd -u #{user}`.split("\n").select do |command|
        command.match?(/Passenger [\w]+App:/)
      end.count
    end
  end
end