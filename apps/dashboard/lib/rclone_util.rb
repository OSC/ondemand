require "json"
require "open3"
require "pathname"

class RcloneUtil

  class << self
    def ls(remote, path)
      full_path = "#{remote}:#{path}"
      # Use lsjson for easy parsing and more info about files
      # Rclone can hang for >20 minutes if remote isn't available and low-level-retries isn't set
      o, e, s = rclone("lsjson", "--low-level-retries=1", full_path)
      if s.success?
        files = JSON.parse(o)
        files
      elsif s.exitstatus == 3 # directory not found
        raise StandardError, "Remote file or directory '#{path}' does not exist"
      else
        raise StandardError, "Error listing files: #{e}"
      end
    end

    def directory?(remote, path)
      # remote:/ will always be a directory
      if path.root?
        return true
      end
      # List everything in parent and check if requested path ends with a slash and actually exists
      full_path = "#{remote}:#{path.parent.to_s}"
      o, e, s = rclone( "lsf", "--low-level-retries=1", full_path)
      if s.success?
        match = o.match(/^(?<entry>#{Regexp.escape(path.basename.to_s)}\/?)$/)
        if match.nil?
          raise StandardError, "Remote file or directory '#{path}' does not exist"
        else
          match[:entry].end_with?("/")
        end
      elsif s.exitstatus == 3 # directory not found
        raise StandardError, "Remote file or directory '#{path}' does not exist"
      else
        raise StandardError, "Error checking info for path: #{e}"
      end
    end

    def mime_type(remote, path)
      # Check first is it is a directory, to avoid strange lsjson behaviour
      # when a directory contains a file with the same name as the directory.
      # `rclone lsjson remote:/name` and `rlcone lsjson remote:/name/name`
      # returns only the info for remote:/name/name
      if directory?(remote, path)
        "inode/directory"
      else
        files = ls(remote, path)
        files.find { |file| file["Path"] == path.basename.to_s }["MimeType"]
      end
    end

    def cat(remote, path)
      full_path = "#{remote}:#{path}"
      o, e, s = rclone("cat", full_path)
      if s.success?
        o
      elsif s.exitstatus == 3 # directory not found
        raise StandardError, "Remote file or directory '#{path}' does not exist"
      else
        raise StandardError, "Error reading file #{full_path}: #{e}"
      end
    end

    def remote_type(remote)
      # Get the rclone remote type (e.g. s3) for a single remote
      o, e, s = rclone("listremotes", "--long")
      if s.success?
        remote = o.lines.grep(/^#{Regexp.escape(remote)}:/).first
        return nil if remote.nil?

        type = remote.split(":")[1].strip
      else
        raise StandardError, "Error getting information about remote: #{e}"
      end
    end

    def rclone_cmd
      # TODO: Make this configurable
      "rclone"
    end

    def rclone(*args)
      Open3.capture3(rclone_cmd, *args)
    end
  end
end
