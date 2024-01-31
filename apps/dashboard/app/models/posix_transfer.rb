# PosixTransfer is a class for transfering local files.
class PosixTransfer < Transfer

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

    names = files.keys.map { |f| File.basename(f) }

    # a move to a different device does a cp then mv
    if action == 'mv' && mv_to_same_device?
      @steps = files.count
    elsif copy?
      @steps = files.keys.map do |source|
        path = Pathname.new(source)
        path.directory? ? Dir["#{source}/**/*"].length : 1
      end.sum
    elsif remove?
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
    @current_cp_step = 0

    files.each do |cp_info|
      src = Pathname.new(cp_info[0])
      dest = Pathname.new(cp_info[1])

      cp_r(src, dest)
    rescue => e
      Rails.logger.warn("error encountered during copy: #{e}")
      errors.add(:copy, e.message)
    end
  end

  def cp_r(src, dest, original_src = nil)
    original_src = src if original_src.nil?
    new_dest = translate_cp_path(src, dest, original_src)

    if src.file? || src.symlink?
      cp_single(src, new_dest)
    elsif src.directory? && src.empty?
      inc_cp_percent
      # TODO: probably need to preserve permissions here.
      FileUtils.mkdir_p(new_dest)
    elsif src.directory? && !src.empty?
      src.each_child { |child| cp_r(child, dest, original_src) }
    end
  end

  def cp_single(src, dest)
    dest_parent = dest.parent.to_s
    # TODO: probably need to preserve permissions here.
    unless File.exist?(dest_parent)
      FileUtils.mkdir_p(dest_parent)
      inc_cp_percent
    end

    if src.symlink?

      # you're symlinking a directory, but the name of the link can differ
      # from the actual directory, so we have to ensure that the name
      # of the new link we're making is the same name as the original
      dest = dest.join(src.basename) if dest.directory?
      FileUtils.symlink(src.readlink, dest)
    else
      # have to get the real path, validate and copy _it_
      # in case it's under a symlink outside of the allowlist.
      real_src = src.realpath
      AllowlistPolicy.default.validate!(real_src.to_s)
      FileUtils.cp(real_src, dest)
    end

    inc_cp_percent
  end

  # you're copying /tmp/dir to /home/users/foo
  # you've descended /tmp/dir down to say /tmp/dir/one/two/three/foo.txt
  # So you want to translate the src - /tmp/dir/one/two/three/foo.txt
  # to the destination path (dest) using relative path one/two/three/foo.txt
  # (relative to the orginal_src which is /tmp/dir)
  def translate_cp_path(src, dest, original_src)

    # no translation needed if you're not descending into a directory
    return dest if src == original_src

    relative_path = src.to_s.gsub("#{original_src}/", '')
    dest.join(relative_path)
  end

  # FIXME: copy commands are the only thing that use their own variable
  # for how many steps it's taken. We should find a way to refactor this.
  def inc_cp_percent
    @current_cp_step += 1
    update_percent(@current_cp_step)
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
