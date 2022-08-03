require "json"
require "open3"
require "pathname"

class RcloneError < StandardError

  attr_reader :exitstatus

  def initialize(exitstatus = 0)
    super
    @exitstatus = exitstatus
  end
end

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
        raise RcloneError.new(s.exitstatus), "Remote file or directory '#{path}' does not exist"
      else
        raise RcloneError.new(s.exitstatus), "Error listing files: #{e}"
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
        raise RcloneError.new(s.exitstatus), "Remote file or directory '#{path}' does not exist"
      else
        raise RcloneError.new(s.exitstatus), "Error checking info for path: #{e}"
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

    def cat(remote, path, &block)
      full_path = "#{remote}:#{path}"
      # Read the file in 32kb chunks
      if block_given?
        rclone_popen("cat", full_path) do |o|
          while data = o.read(32768)
            yield data
          end
        end
      else
        # Read the whole file
        o, e, s = rclone("cat", full_path)
        if s.success?
          o
        elsif s.exitstatus == 3 # directory not found
          raise RcloneError.new(s.exitstatus), "Remote file or directory '#{path}' does not exist"
        else
          raise RcloneError.new(s.exitstatus), "Error reading file #{full_path}: #{e}"
        end
      end
    end

    def touch(remote, path)
      full_path = "#{remote}:#{path}"
      o, e, s = rclone("touch", full_path)
      if !s.success?
        raise RcloneError.new(s.exitstatus), "Error creating file: #{e}"
      end
    end

    def mkdir(remote, path)
      full_path = "#{remote}:#{path}"
      o, e, s = rclone("mkdir", full_path)
      if e.include?("Warning: running mkdir on a remote which can't have empty directories does nothing")
        # TODO: Could most likely do some kind of workaround here, e.g. rclone touch remote:path/.somefile
        raise RcloneError.new(s.exitstatus), "Remote does not support empty directories"
      elsif !s.success?
        raise RcloneError.new(s.exitstatus), "Error creating directory: #{e}"
      end
    end

    def write(remote, path, content)
      full_path = "#{remote}:#{path}"
      # Write to a file on the remote by passing the file contents in stdin
      o, e, s = rclone("rcat", full_path, stdin_data: content)
      if !s.success?
        raise RcloneError.new(s.exitstatus), "Error writing file: #{e}"
      end
    end

    def moveto(remote, path, src)
      full_path = "#{remote}:#{path}"
      # Move file src on the local filesystem to full_path on the remote
      o, e, s = rclone("moveto", src, full_path)
      if !s.success?
        raise RcloneError.new(s.exitstatus), "Error moving file: #{e}"
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
        raise RcloneError.new(s.exitstatus), "Error getting information about remote: #{e}"
      end
    end

    def rclone_cmd
      # TODO: Make this configurable
      "rclone"
    end

    def rclone(*args)
      Open3.capture3(rclone_cmd, *args)
    end

    def rclone_popen(*args, stdin_data: nil, &block)
      # Use -q to suppress message about config file not existing
      # need it here as we check err.present?
      Open3.popen3(rclone_cmd, "--quiet", *args) do |i, o, e, t|
        if stdin_data
          i.write(stdin_data)
        end
        i.close

        err_reader = Thread.new { e.read }

        yield o

        o.close
        exit_status = t.value
        err = err_reader.value.to_s.strip
        if err.present? || !exit_status.success?
          raise RcloneError.new(exit_status.exitstatus), "Rclone exited with status #{exit_status.exitstatus}\n#{err}"
        end
      end
    end
  end
end
