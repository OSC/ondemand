require 'find'  # remove this
require 'pathname'
require 'zip'

class FileSystem::Operation
    def copy(src, dst)
        FileUtils.cp_r(src, dst, preserve: true)
    rescue Errno::ENOTDIR, Errno::EEXIST, Errno::EACCES => e
        raise FileSystem::Error, e
    end

    # Look into streaming the file from controller
    def self.archive_in_memory(src)
        Dir.chdir(src.parent) do
            parent = src.parent.to_s + '/'
            stringio = Zip::OutputStream.write_buffer do |zip|
                src.find.each do |entry|
                    if entry.directory?
                        zip.put_next_entry entry.to_s.gsub(parent, '') + '/'
                    else
                        zip.put_next_entry entry.to_s.gsub(parent, '')
                    end
                end
            end

            stringio.rewind
            stringio.read
        end
    end

    def self.delete(path)
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

    def move(src, dst)
        Pathname.new(src.to_s).rename(dst.to_s)
    rescue Errno::EACCES => e
        raise FileSystem::Error, e
    end
    alias_method :rename, :move     
end