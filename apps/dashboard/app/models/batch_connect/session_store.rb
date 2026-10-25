# frozen_string_literal: true

require 'tempfile'

module BatchConnect
  # Coordinate record replacement, quarantine and deletion across PUN workers.
  class SessionStore
    def initialize(root)
      @root = root
    end

    def read_all(&parser)
      synchronize do
        @root.children.select(&:file?).reject { |path| path.extname == '.bak' }.filter_map do |path|
          read_record(path, &parser)
        end
      end
    end

    def read(id)
      synchronize { @root.join(id).read }
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

    def synchronize
      # Keep this lock inode stable: replacing/unlinking it breaks coordination.
      File.open(metadata_directory.join('lock'), File::RDWR | File::CREAT, 0o600) do |lock|
        lock.flock(File::LOCK_EX)
        yield
      end
    end

    def read_record(path)
      yield path.read
    rescue Errno::ENOENT
      nil
    rescue StandardError => e
      Rails.logger.error("ERROR: Error parsing file '#{path}' --- #{e.class} - #{e.message}")
      begin
        path.rename("#{path}.bak")
      rescue Errno::ENOENT
        # Another operation may have removed the record.
      end
      nil
    end
  end
end
