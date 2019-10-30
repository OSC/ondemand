class Task
    attr_reader :type, :target, :progress

    def initialize(type:, target:, progress:)
        @progress = progress
        @target = target
        @type = type
    end
end