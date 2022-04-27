class LocalTransfer < Transfer

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
  end

  # number of files to copy, move or delete
  def steps
    return @steps if @steps

    names = files.keys.map {|f| File.basename(f)}

    # a move to a different device does a cp then mv
    if action == 'mv' && mv_to_same_device?
      @steps = files.count
    else
      @steps = PosixFile.num_files(from, names)
      @steps *= 2 if action == 'mv'
    end

    @steps
  end

  # array of arguments that will be executed
  def command
    # command is executed in the directory containing the "from" files

    if action == 'mv'
      args = [action.to_s, '-v']

      if files.count == 1
        # for renaming a single file
        # { file_src => file_dest} changes to [file_src, file_dest] and absolute paths are fine here
        args += files.to_a.flatten
      else
        args += files.keys.map { |f| File.basename(f) }
        args << to
      end
    elsif action == 'cp'
      args = [action.to_s, '-v']
      args << '-r'
      args += files.keys.map { |f| File.basename(f) }
      args << to
    elsif action == 'rm'
      args = [action.to_s, '-v']
      args << '-r'

      args += files.keys
    else
      raise "Unknown action: #{action.inspect}"
    end

    args
  end

  def perform
    self.status = OodCore::Job::Status.new(state: :running)
    self.started_at = Time.now.to_i

    # calculate number of steps prior to starting the removal of files
    steps

    Open3.popen3(*command, chdir: from) do |i, o, e, t|
      self.pid = t.pid

      err_reader = Thread.new { e.read  }

      o.each_line.with_index do |l, index|
        #FIXME: slice(?).last so that we only update progress a few times per...
        update_percent(index+1)
      end
      o.close

      self.exit_status = t.value
      self.completed_at = Time.now.to_i

      # FIXME: figure out what we are going to do here, since we save the stderr output twice
      self.stderr = err_reader.value.to_s.strip
      if self.stderr.present? || ! self.exit_status.success?
        errors.add :base, "#{self.command} exited with status #{self.exit_status.exitstatus}\n\n#{self.stderr}"
      end

      self
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
end
