require "pathname"

class Location
    attr_reader :path, :name

    def initialize(path:, name:)
        @path = Pathname.new(path)
        @name = name
    end
end