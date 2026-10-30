# frozen_string_literal: true

module BatchConnect
  # The caller holds the store lock or has stopped every writer before deletion.
  class SessionStoreCleanup
    TEMPORARY_NAME = /\Asession-\d{8}-\d+-[a-z0-9]+(?:-\d+)?\z/.freeze

    def initialize(root)
      @directory = root.join('.session-store')
    end

    def available?
      stat = @directory.lstat
      current = [stat.dev, stat.ino]
      safe = stat.directory? && stat.uid == Process.euid && (stat.mode & 0o022).zero?
      unless safe && (@directory_identity.nil? || @directory_identity == current)
        raise ArgumentError, "Unsafe or replaced session-store metadata directory: #{@directory}"
      end

      @directory_identity = current
      true
    rescue Errno::ENOENT
      false
    end

    def call(older_than:, dry_run:)
      age = Float(older_than)
      raise ArgumentError, 'older_than must be finite and nonnegative' unless age.finite? && age >= 0
      return [] unless available?

      cutoff = Time.now - age
      @directory.children.select do |path|
        clean_candidate(path, cutoff: cutoff, dry_run: dry_run)
      end
    end

    private

    def clean_candidate(path, cutoff:, dry_run:)
      return false unless TEMPORARY_NAME.match?(path.basename.to_s)

      stat = path.lstat
      return false unless stale_owned_file?(stat, cutoff)
      return true if dry_run

      # Cooperating writers are excluded; preserve a path changed by an external writer.
      current = path.lstat
      return false unless identity(current) == identity(stat)

      path.unlink
      true
    rescue Errno::ENOENT
      false
    end

    def identity(stat)
      [stat.dev, stat.ino, stat.mode, stat.uid, stat.nlink, stat.mtime, stat.ctime]
    end

    def stale_owned_file?(stat, cutoff)
      stat.file? && stat.uid == Process.euid && stat.nlink == 1 && stat.mtime < cutoff
    end
  end
end
