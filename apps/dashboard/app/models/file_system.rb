module FileSystem
    require 'file_system/entry'
    require 'file_system/errors'
    require 'file_system/operation'

    def self.home_dir
        Pathname.new(ENV['HOME'])
    end
end
