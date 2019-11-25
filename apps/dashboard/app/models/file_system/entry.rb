require 'shellwords'

module FileSystem
    class Entry
        attr_reader :basename, :fs_type, :group, :mime_type, :modified, :owner, :path, :permissions, :size

        def self.from_pathname(path)
            stat = path.stat

            new(
                basename: path.basename,
                fs_type: path.ftype.to_sym,
                group: self.get_groupname(stat.gid),
                mime_type: get_mimetype(path),
                modified: stat.mtime.to_i,
                owner: self.get_username(stat.uid),
                path: path.to_s,
                permissions: stat.mode.to_s(8).to_i % 1000,
                size: stat.size,
            )
        end

        def initialize(basename:, group:, mime_type:, modified:, owner:, path:, permissions:, size:, fs_type:)
            @basename = basename
            @fs_type = fs_type
            @group = group
            @mime_type = mime_type
            @modified = modified
            @owner = owner
            @path = path
            @permissions = permissions
            @size = size
        end

        def to_h
            {
                basename: basename,
                group: group,
                mime_type: mime_type,
                modified: modified,
                owner: owner,
                path: path,
                permissions: permissions,
                size: size,
            }
        end

        private

        def self.get_groupname(gid)
            Etc.getgrgid(gid).name
        rescue ArgumentError  # cannot find group for GID
            gid.to_s
        end

        def self.get_username(uid)
            Etc.getpwuid(uid).name
        rescue ArgumentError  # cannot find user for UID
            uid.to_s
        end

        def self.get_mimetype(path)
            if path.directory?
                'directory'
            else
                `file --brief --mime-type - < #{Shellwords.shellescape(path.to_s)}`.strip
            end
        rescue
            'application/octet-stream'
        end
    end
end