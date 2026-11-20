# PosixTransfer is a class for transferring local files.
class PosixTransfer < Transfer

  COPY_ENTRY_TYPES = %w[directory file link].freeze

  validates_each :files do |record, _attr, files|

    if record.move? || record.copy?
      conflicts = files.values.select { |f| File.exist?(f) }
      record.errors.add :files, "these files already exist: #{conflicts.join(', ')}" if conflicts.present?

      non_existant = files.keys.reject { |f| File.exist?(f) }
      record.errors.add :files, "cannot copy or move files that do not exist: #{non_existant.join(', ')}" if non_existant.present?
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

    # a move to a different device does a cp then mv
    if action == 'mv' && mv_to_same_device?
      @steps = files.count
    elsif copy?
      @steps = files.keys.sum do |source|
        case copy_entry_type(source)
        when 'directory'
          # Count the root separately, since the glob can also return it as '.'.
          1 + Dir.glob('**/*', File::FNM_DOTMATCH, base: source, sort: false).count do |entry|
            entry != '.' && COPY_ENTRY_TYPES.include?(copy_entry_type(File.join(source, entry)))
          end
        when 'file', 'link', nil
          # Keep one planned step for a source whose type could not be read.
          1
        else
          0
        end
      end
    elsif remove?
      @steps = files.size
    else
      names = files.keys.map { |f| File.basename(f) }
      @steps = PosixFile.num_files(from, names)
      @steps *= 2 if action == 'mv'
    end

    @steps
  end

  def copy_entry_type(path)
    File.ftype(path)
  rescue SystemCallError
    nil
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
    @current_cp_step = 0

    files.each do |cp_info|
      src = Pathname.new(cp_info[0])
      dest = Pathname.new(cp_info[1])

      validate_copy_destination(src, dest)
      cp_r(src, dest)
    rescue => e
      Rails.logger.warn("error encountered during copy: #{e}")
      errors.add(:copy, e.message)
    end
  end

  def validate_copy_destination(src, dest)
    return if src.symlink? || !src.directory?
    return unless resolve_copy_destination(dest).ascend.include?(src.realpath)

    raise ArgumentError, "cannot copy a directory into itself: #{src} to #{dest}"
  end

  def resolve_copy_destination(path)
    path.realdirpath
  rescue Errno::ENOENT
    parent = path.dirname
    raise if parent == path

    resolve_copy_destination(parent).join(path.basename)
  end

  def cp_r(src, dest)
    case File.ftype(src)
    when 'file', 'link'
      cp_single(src, dest)
    when 'directory'
      children = src.children
      FileUtils.mkdir_p(dest.parent)
      if children.empty?
        Dir.mkdir(dest, src.stat.mode & 0o1777)
      else
        # Keep partial copies private while populating their contents.
        Dir.mkdir(dest, 0o700)
        final_mode = copied_directory_mode(src, dest)
        children.each { |child| cp_r(child, dest.join(child.basename)) }
        # Linux can clear inherited setgid on chmod when the copier is outside
        # the destination group. Leave the mode alone when mkdir already set it.
        dest.chmod(final_mode) unless (dest.stat.mode & 0o3777) == final_mode
      end
      inc_cp_percent
    end
  end

  def copied_directory_mode(src, dest)
    mode = dest.stat.mode
    dest.chmod(0o700 | (mode & 0o2000)) if (mode & 0o700) != 0o700

    # The new destination inherited the parent's default ACL and setgid bit.
    # Let mkdir apply them (or the umask) inside this still-private directory.
    probe = dest.join('.ondemand-copy-mode')
    Dir.mkdir(probe, src.stat.mode & 0o1777)
    begin
      probe.stat.mode & 0o3777
    ensure
      Dir.rmdir(probe)
    end
  end

  def cp_single(src, dest)
    FileUtils.mkdir_p(dest.parent)

    if src.symlink?
      File.symlink(src.readlink, dest)
    else
      # have to get the real path, validate and copy _it_
      # in case it's under a symlink outside of the allowlist.
      real_src = src.realpath
      AllowlistPolicy.default.validate!(real_src.to_s)
      File.open(real_src, 'rb') do |source|
        flags = File::WRONLY | File::CREAT | File::EXCL | File::BINARY
        File.open(dest, flags, source.stat.mode) do |target|
          IO.copy_stream(source, target)
        end
      end
    end

    inc_cp_percent
  end

  # FIXME: copy commands are the only thing that use their own variable
  # for how many steps it's taken. We should find a way to refactor this.
  def inc_cp_percent
    @current_cp_step += 1
    update_percent([@current_cp_step, steps].min)
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
