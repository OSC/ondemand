require 'pathname'

class FileSystem::Operation
    def copy(src, dst)
        FileUtils.cp_r(src, dst, preserve: true)
    rescue Errno::ENOTDIR, Errno::EEXIST, Errno::EACCES => e
        raise FileSystem::Error, e
    end

    def delete(path)
        Pathname.new(path.to_s).rmtree
    rescue Errno::ENOTDIR, Errno::EACCES => e
        raise FileSystem::Error, e
    end

    def get(path)
        Pathname.new(path.to_s).read
    end

    def list(path)
        path = Pathname.new(path.to_s)

        if path.directory? && path == Pathname.new('/')
            path.children
        elsif path.directory?
            [Pathname.new(path).join('..')] + path.children
        elsif path.file?
            [path]
        elsif ! path.exist?
            raise FileSystem::EntryDNE, "Entry #{path.to_s} does not exist"
        else
            raise FileSystem::Error, 'Unhandled file type'
        end
    rescue Errno::ENOTDIR, Errno::EACCES => e
        raise FileSystem::Error, e
    end     

    def move
    end
    alias_method :rename, :move     
end