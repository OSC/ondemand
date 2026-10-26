# frozen_string_literal: true

require 'tempfile'

module BatchConnect
  # Replace records atomically, with optional coordination across PUN workers.
  class SessionStore
    class LockUnavailable < StandardError; end

    UNSUPPORTED_LOCK_ERRORS = [Errno::ENOLCK, Errno::ENOSYS, Errno::EOPNOTSUPP].freeze

    def initialize(root, locking: false)
      @root = root
      @locking = locking
    end

    def read_all(&parser)
      synchronize(read_only: true) do |locked|
        @root.children.select(&:file?).reject { |path| path.extname == '.bak' }.filter_map do |path|
          read_record(path, quarantine: locked, &parser)
        end
      end
    end

    def read(id)
      synchronize(read_only: true) { @root.join(id).read }
    end

    # Check the temporary directory and optional lock before scheduler side effects.
    def prepare!
      metadata_directory
      synchronize { true }
    end

    def write(id, contents, create: false)
      synchronize do
        path = @root.join(id)
        next false unless create || path.file?

        Tempfile.create('session-', metadata_directory) do |file|
          file.write(contents)
          file.flush
          File.rename(file.path, path)
        end
        true
      end
    end

    def delete(id)
      synchronize do
        @root.join(id).delete
      rescue Errno::ENOENT
        # Concurrent deletion already achieved the requested state.
      end
      true
    end

    private

    def metadata_directory
      directory = @root.join('.session-store')
      begin
        directory.mkdir(0o700)
      rescue Errno::EEXIST
        raise unless directory.directory?
      end
      directory
    end

    def synchronize(read_only: false)
      # Without coordination, never quarantine a pathname another writer may replace.
      return yield(false) unless @locking

      # Keep this lock inode stable: replacing/unlinking it breaks coordination.
      File.open(metadata_directory.join('lock'), File::RDWR | File::CREAT, 0o600) do |lock|
        locked = acquire_lock(lock, read_only: read_only)
        yield locked
      end
    end

    def acquire_lock(lock, read_only:)
      return true if lock.flock(File::LOCK_EX)

      raise LockUnavailable, "Cannot acquire session database lock for #{@root}"
    rescue *UNSUPPORTED_LOCK_ERRORS => e
      message = "Session database locking unavailable for #{@root}: #{e.message}"
      raise LockUnavailable, message unless read_only

      Rails.logger.warn("#{message}; allowing read-only access without quarantine")
      false
    end

    def read_record(path, quarantine:)
      yield path.read
    rescue Errno::ENOENT
      nil
    rescue StandardError => e
      Rails.logger.error("ERROR: Error parsing file '#{path}' --- #{e.class} - #{e.message}")
      return nil unless quarantine

      begin
        path.rename("#{path}.bak")
      rescue Errno::ENOENT
        # Another operation may have removed the record.
      end
      nil
    end
  end
end
