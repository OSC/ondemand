module FileSystem
    class Error < StandardError; end
    class EntryDNE < Error; end
    class EPERM < Error; end
end