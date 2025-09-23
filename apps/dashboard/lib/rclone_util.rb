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

  # Treat remotes with name `fs` as the local (posix) filesystem
  LOCAL_FS_NAME = 'fs'

  # Regex for parsing progress of Rclone transfers in stdout of the commands
  # e.g. Transferred:        1.575 GiB / 1.971 GiB, 80%, 537.544 MiB/s, ETA 0s
  # or in newer Rclone: Transferred:   	    1.162Gi / 1.971 GiByte, 59%, 44.895 MiByte/s, ETA 18s
  PROGRESS_REGEX = /Transferred:\s+[\d.]+ ?\w+ \/ [\d.]+ \w+, (?<progress>\d+)%/

  class << self
    def remote_path(remote, path)
      if remote == LOCAL_FS_NAME
        path
      else
        "#{remote}:#{path}"
      end
    end

    def ls(remote, path)
      full_path = remote_path(remote, path)
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

    # Simple list of files and directories
    def lsf(remote, path)
      full_path = remote_path(remote, path)
      # Rclone can hang for >20 minutes if remote isn't available and low-level-retries isn't set
      o, e, s = rclone("lsf", "--low-level-retries=1", "--dir-slash=false", full_path)
      if s.success?
        files = o.lines.map(&:strip)
        files
      elsif s.exitstatus == 3 # directory not found
        raise RcloneError.new(s.exitstatus), "Remote file or directory '#{path}' does not exist"
      else
        raise RcloneError.new(s.exitstatus), "Error listing files: #{e}"
      end
    end

    def directory?(remote, path)
      path = Pathname.new(path)
      # remote:/ will always be a directory
      if path.root?
        return true
      end

      if remote_type(remote) == "s3"
        # Alternative way to check if a path exists in S3 by looking at acceptable file sizes
        full_path = remote_path(remote, path)
        o, e, s = rclone( "test", "info", "--check-length", full_path)

        if s.success?
          match = o.match(/^(?<entry>maxFileLength = [0-9]+)/)
          if match.nil?
            raise StandardError, "Remote file or directory '#{path}' does not exist, CAN lsf '#{o}'"
          else
            return true
          end
        elsif s.exitstatus == 3 # directory not found
          raise RcloneError.new(s.exitstatus), "Remote file or directory '#{path}' does not exist OR can't lsf"
        else
          raise RcloneError.new(s.exitstatus), "Error checking info for path: #{e}"
        end

      else
        # List everything in parent and check if requested path ends with a slash and actually exists
        full_path = remote_path(remote, path.parent.to_s)
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
      full_path = remote_path(remote, path)
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
      full_path = remote_path(remote, path)
      o, e, s = rclone("touch", full_path)
      if !s.success?
        raise RcloneError.new(s.exitstatus), "Error creating file: #{e}"
      end
    end

    def mkdir(remote, path)
      path = Pathname.new(path)
      full_path = remote_path(remote, path)
      o, e, s = rclone("mkdir", full_path)
      if e.include?("Warning: running mkdir on a remote which can't have empty directories does nothing")
        # Workaround for remotes that don't support empty directories.
        # Touch a .directory file in the directory that is being created
        begin
          touch(remote, path.join(".keep"))
          if !directory?(remote, path)
            raise StandardError, I18n.t("dashboard.files_remote_dir_not_created", path: path.to_s)
          end
        rescue RcloneError => e # Actual error messages from touch and directory? are not relevant, raise new error
          raise RcloneError.new(s.exitstatus), I18n.t("dashboard.files_remote_empty_dir_unsupported")
        end
      elsif !s.success?
        raise RcloneError.new(s.exitstatus), "Error creating directory: #{e}"
      end
    end

    def write(remote, path, content)
      full_path = remote_path(remote, path)
      # Write to a file on the remote by passing the file contents in stdin
      o, e, s = rclone("rcat", full_path, stdin_data: content)
      if !s.success?
        raise RcloneError.new(s.exitstatus), "Error writing file: #{e}"
      end
    end

    def moveto(remote, path, src)
      full_path = remote_path(remote, path)
      # Move file src on the local filesystem to full_path on the remote
      o, e, s = rclone("moveto", src, full_path)
      if !s.success?
        raise RcloneError.new(s.exitstatus), "Error moving file: #{e}"
      end
    end

    def moveto_with_progress(src_remote, dest_remote, src_path, dest_path, &block)
      full_src_path = remote_path(src_remote, src_path)
      full_dest_path = remote_path(dest_remote, dest_path)
      RcloneUtil.rclone_with_progress(
        "moveto",
        full_src_path,
        full_dest_path,
        &block
      )
    end

    def copyto_with_progress(src_remote, dest_remote, src_path, dest_path, &block)
      full_src_path = remote_path(src_remote, src_path)
      full_dest_path = remote_path(dest_remote, dest_path)
      RcloneUtil.rclone_with_progress(
        "copyto",
        full_src_path,
        full_dest_path,
        &block
      )
    end

    def remove_with_progress(remote, path, &block)
      full_path = remote_path(remote, path)
      dir = directory?(remote, path)
      if dir
        # rclone delete doesn't seem to delete an empty directory even if we would want to delete it
        # using purge instead
        RcloneUtil.rclone_with_progress("purge", full_path, &block)
      else
        RcloneUtil.rclone_with_progress("delete", full_path, &block)
      end
    end

    def size(remote, path)
      full_path = remote_path(remote, path)
      # Move file src on the local filesystem to full_path on the remote
      o, e, s = rclone("size", "--json", full_path)
      if s.success?
        # rclone returns e.g. {"count":40,"bytes":2303928506}
        JSON.parse(o)
      elsif s.exitstatus == 3 # directory not found
        raise RcloneError.new(s.exitstatus), "Remote file or directory '#{path}' does not exist"
      else
        raise RcloneError.new(s.exitstatus), "Error getting file or directory size: #{e}"
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

    # Lists remotes configured in default rclone.conf or environment variables
    # @return [Array<String>] Rclone remotes
    def list_remotes
      o, e, s = rclone("listremotes")
      if s.success?
        o.lines.map { |l| l.strip.delete_suffix(":") }
      else
        raise RcloneError.new(s.exitstatus), I18n.t("dashboard.files_remote_error_listing_remotes", error: e)
      end
    end

    # Check if remote can be accessed (responds to directory listing request).
    def valid?(remote)
      # This gives a total max duration of 6s (2s * 3 attempts)
      _, _, s = rclone(
        'lsd',                 "#{remote}:",
        '--contimeout',        '2s',
        '--timeout',           '2s',
        '--low-level-retries', '1',
        '--retries',           '1'
      )
      s.success?
    rescue StandardError
      false
    end

    # Gets the config from OOD_RCLONE_EXTRA_CONFIG file as a Hash of env vars.
    # @return [Hash] environment variables corresponding to config
    def extra_config
      return {} if Configuration.rclone_extra_config.blank?

      # Rclone config dump outputs the configured remotes as JSON.
      # TODO: Cache these results when generating favorite paths?
      o, _, s = rclone('config', 'dump', env: { 'RCLONE_CONFIG' => Configuration.rclone_extra_config })
      return {} unless s.success?

      remotes = JSON.parse(o)

      # Combine config into a single Hash where keys and values are e.g.
      # RCLONE_CONFIG_MYREMOTE_TYPE: "s3"
      remotes.map do |remote_name, remote_config|
        remote_config.transform_keys do |option|
          "RCLONE_CONFIG_#{remote_name}_#{option}".upcase
        end
      end.reduce(&:merge) || {} # reduce on empty array returns nil
    rescue StandardError => e
      Rails.logger.error("Could not read extra Rclone configuration: #{e.message}")
      {}
    end

    def rclone_cmd
      # TODO: Make this configurable
      "rclone"
    end

    def rclone(*args, env: extra_config, **kwargs)
      # config/initalizers/open3_extensions.rb overrides Open3.capture3 to log calls.
      # Get a reference to the original method to avoid logging the sensitive env vars.
      Open3.singleton_method(:capture3).call(env, rclone_cmd, *args, **kwargs)
    end

    def rclone_popen(*args, stdin_data: nil, env: extra_config, &block)
      # Use -q to suppress message about config file not existing
      # need it here as we check err.present?
      Open3.popen3(env, rclone_cmd, "--quiet", *args) do |i, o, e, t|
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

    # Calls rclone and parses stdout to track the progress of the command, yields the percentage
    def rclone_with_progress(*args, &block)
      rclone_popen("--progress", *args) do |o|
        o.each_line do |line|
          match = line.match(PROGRESS_REGEX)
          if match
            progress = match[:progress].to_i
            yield progress
          end
        end
      end
    end
  end
end
