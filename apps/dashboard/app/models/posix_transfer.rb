# PosixTransfer is a class for transfering local files.
class PosixTransfer < Transfer

  validates_each :files do |record, attr, files|
    if record.action == 'mv' || record.action == 'cp'
      conflicts = files.values.select { |f| File.exist?(f) }
      record.errors.add :files, "these files already exist: #{conflicts.join(', ')}" if conflicts.present?
    end

    files.each do |k, v|
      record.errors.add :files, "#{k} is not included under ALLOWLIST_PATH" unless AllowlistPolicy.default.permitted?(k.to_s)
      # rm commands are [{ k => nil}] - nil values
      record.errors.add :files, "#{v} is not included under ALLOWLIST_PATH" if !v.nil? && !AllowlistPolicy.default.permitted?(v.to_s)
    end
  end

  class << self
    def transfers
      # all transfers stored in the Transfer class
      Transfer.transfers
    end

    def build(action:, files:)
      if files.is_a?(Array)
        # rm action will want to provide an array of files
        # so if it is an Array we convert it to a hash:
        #
        # convert [a1, a2, a3] to {a1 => nil, a2 => nil, a3 => nil}
        files = Hash[files.map { |f| [f, nil] }].with_indifferent_access
      end

      self.new(action: action, files: files)
    end
  end

  # number of files to copy, move or delete
  def steps
    return @steps if @steps

    names = files.keys.map { |f| File.basename(f) }

    # a move to a different device does a cp then mv
    if action == 'mv' && mv_to_same_device?
      @steps = files.count
    elsif remove? || copy?
      @steps = names.size
    else
      # TODO: num_files issues 'find' command. so likely needs optimized
      @steps = PosixFile.num_files(from, names)
      @steps *= 2 if action == 'mv'
    end

    @steps
  end

  # PosixTransfer no longer issues CLI commands to transfer files.
  def commands
    []
  end

  def perform
    self.status = OodCore::Job::Status.new(state: :running)
    self.started_at = Time.now.to_i

    # calculate number of steps prior to starting the removal of files
    steps

    action_sym = action.to_sym
    if respond_to?(action_sym)
      send(action_sym)
      complete!
    else
      errors.add(:base, "Unknown action: #{action.inspect}")
    end

  rescue => e
    errors.add :base, e.message
  ensure
    self.status = OodCore::Job::Status.new(state: :completed)
  end

  def from
    File.dirname(files.keys.first) if files.keys.first
  end

  def to
    File.dirname(files.values.first) if files.values.first
  end

  def target_dir
    # directory where files are being moved/copied to OR removed from
    if action == "rm"
      Pathname.new(from).cleanpath if from
    else
      Pathname.new(to).cleanpath if to
    end
  end

  def synchronous?
    mv_to_same_device?
  end

  def mv_to_same_device?
    action == "mv" && from && to && PosixFile.stat(from)[:dev] == PosixFile.stat(File.dirname(to))[:dev]
  end

  def rm
    files.keys.each_with_index do |file, idx|
      FileUtils.remove_entry_secure(file)
      update_percent(idx + 1)
    rescue => e
      errors.add(:remove, e.message)
    end
  end

  def cp
    files.each_with_index do |cp_info, idx|
      src = cp_info[0]
      dest = cp_info[1]
      FileUtils.cp_r(src, dest)
      update_percent(idx + 1)
    rescue => e
      errors.add(:copy, e.message)
    end
  end

  def mv
    files.each_with_index do |cp_info, idx|
      src = cp_info[0]
      dest = cp_info[1]
      FileUtils.move(src, dest, secure: true)
      update_percent(idx + 1)
    end
  rescue => e
    errors.add(:move, e.message)
  end
end
