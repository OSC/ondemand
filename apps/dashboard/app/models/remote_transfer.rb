# RemoteTransfer is a class for transfering remote files.
class RemoteTransfer < Transfer

  validates_each :src_remote, :dest_remote do |record, _, remote|
    remote_type = RcloneUtil.remote_type(remote)
    if remote_type.nil? && remote != RcloneUtil::LOCAL_FS_NAME
      record.errors.add :base, "Remote #{remote} does not exist"
    elsif ::Configuration.allowlist_paths.present? && (remote_type == 'local' || remote_type == 'alias')
      record.errors.add :base, "Remotes of type #{remote_type} are not allowed due to ALLOWLIST_PATH"
    end
  end

  validates_each :files do |record, _, files|
    files.each do |k, v|
      # Validate paths in the same was as PosixTransfer for the local filesystem (fs)
      if record.src_remote == RcloneUtil::LOCAL_FS_NAME
        record.errors.add :base, "#{k} is not included under ALLOWLIST_PATH" unless AllowlistPolicy.default.permitted?(k.to_s)
      end
      if record.dest_remote == RcloneUtil::LOCAL_FS_NAME
        # rm commands are [{ k => nil}] - nil values
        record.errors.add :base, "#{v} is not included under ALLOWLIST_PATH" if !v.nil? && !AllowlistPolicy.default.permitted?(v.to_s)
      end
    end

    if record.action == 'mv' || record.action == 'cp'
      # local filesystem
      if record.dest_remote == RcloneUtil::LOCAL_FS_NAME
        conflicts = files.values.select { |f| File.exist?(f) }
        record.errors.add :base, "These files already exist: #{conflicts.join(', ')}" if conflicts.present?
      else
        # remote
        begin
          existing = RcloneUtil.lsf(record.dest_remote, record.to).map { |file| File.join(record.to, file) }
          conflicts = files.values.intersection(existing)
          record.errors.add :base, "These files already exist: #{conflicts.join(', ')}" if conflicts.present?
        rescue RcloneError => e
          if e.exitstatus != 3
            # Rclone will return status 3 if directory doesn't exist (ok), other errors are unexpected
            record.errors.add :base, "Error checking existing files in destination: #{e}"
          end
        end
      end
    end
  end

  attr_accessor :src_remote, :dest_remote, :tempfile, :filesizes, :transferred

  class << self
    def transfers
      # all transfers stored in the Transfer class
      Transfer.transfers
    end

    def build(action:, files:, src_remote:, dest_remote:, tempfile: nil)
      if files.is_a?(Array)
        # rm action will want to provide an array of files
        # so if it is an Array we convert it to a hash:
        #
        # convert [a1, a2, a3] to {a1 => nil, a2 => nil, a3 => nil}
        files = Hash[files.map { |f| [f, nil] }].with_indifferent_access
      end
      self.new(action: action, files: files, src_remote: src_remote, dest_remote: dest_remote, tempfile: tempfile)
    end
  end

  # total number of bytes
  def steps
    return @steps if @steps

    @filesizes = {}.with_indifferent_access

    # Get info from `rclone size` (will not work on Google Drive and Google Photos)
    total_size = files.keys.map do |file|
      size = RcloneUtil.size(src_remote, file).fetch('bytes', 0)
      @filesizes[file] = { :size => size, :transferred => 0 }
      size
    end.sum

    @steps = total_size
  end

  def command_str
    ''
  end

  def increment_transferred(amount)
    @transferred = transferred.to_i + amount
  end

  # Updates the total progress with progress of one file since last update
  def update_progress(file, percent_done)
    file_info = filesizes[file]

    current_bytes = (percent_done * file_info[:size]) / 100
    since_last = current_bytes - file_info[:transferred]
    filesizes[file][:transferred] = current_bytes

    increment_transferred(since_last)
    update_percent(transferred)
  end

  def perform
    self.status = OodCore::Job::Status.new(state: :running)
    self.started_at = Time.now.to_i

    # Store info about sizes of files to transfer for tracking progress
    steps

    # Transfer each file/directory indiviually
    files.each do |src, dst|
      if action == 'mv'
        RcloneUtil.moveto_with_progress(src_remote, dest_remote, src, dst) do |p|
          update_progress(src, p)
        end
      elsif action == 'cp'
        RcloneUtil.copyto_with_progress(src_remote, dest_remote, src, dst) do |p|
          update_progress(src, p)
        end
      elsif action == 'rm'
        RcloneUtil.remove_with_progress(src_remote, src) do |p|
          update_progress(src, p)
        end
      else
        raise StandardError, "Unknown action: #{action.inspect}"
      end
    rescue RcloneError => e
      # TODO: catch more rclone specific errors here, i.e. if the access keys are invalid it would make
      # sense to not attempt to transfer the rest of the files
      errors.add :base, "Error when transferring #{src}: #{e.message}"
    end
  rescue => e
    errors.add :base, e.message
  ensure
    self.status = OodCore::Job::Status.new(state: :completed)
    tempfile&.close(true)
  end

  def from
    File.dirname(files.keys.first) if files.keys.first
  end

  def to
    File.dirname(files.values.first) if files.values.first
  end

  def target_dir
    # directory where files are being moved/copied to OR removed from
    if action == 'rm'
      Pathname.new(from).cleanpath if from
    else
      Pathname.new(to).cleanpath if to
    end
  end

  def synchronous?
    false
  end
end
