class Transfer
  include ActiveModel::Model
  include ActiveModel::Validations
  include GlobalID::Identification

  # for progress tracking and retrieval
  attr_accessor :id, :status, :created_at, :started_at, :completed_at
  attr_writer :percent

  validates_each :files do |record, attr, value|
    if record.action == 'mv' || record.action == 'cp'
      conflicts = value.values.select {|f| File.exist?(f) }
      record.errors.add :files, "these files already exist: #{conflicts.join(', ')}" if conflicts.present?
    end
  end

  def percent
    (status && status.completed?) ? 100 : (@percent || 0)
  end

  attr_accessor :exit_status, :stderr

  attr_accessor :pid

  # files could either be an array of strings or an array of hashes (string=>string)
  attr_accessor :action, :files

  class << self
    def transfers
      @transfers ||= []
    end

    def find(id)
      transfers.find {|t| t.id == id }
    end

    def build(action:, files:)
      if files.kind_of?(Array)
        # rm action will want to provide an array of files
        # so if it is an Array we convert it to a hash:
        #
        # convert [a1, a2, a3] to {a1 => nil, a2 => nil, a3 => nil}
        files = Hash[files.map {|f| [f, nil]}]
      end

      Transfer.new(action: action, files: files)
    end
  end

  def bootstrap_class
    # TODO: if error occurs, need to display error label! (and pop error alert above page)
    if status&.completed?
      'success'
    elsif status&.running?
      'info'
    else
      'default'
    end
  end

  def fa_label
    if status&.completed?
      'fa-check'
    elsif status&.running?
      'fa-spinner fa-spin'
    else
      'fa-pause'
    end
  end

  def action_title
    t = status&.queued? ? 'waiting to ' : ''

    if action == 'mv'
      t + 'move files'
    elsif action == 'rm'
      t + 'remove files'
    elsif action == 'cp'
      t + 'copy files'
    else
      t + "#{action} files"
    end
  end

  def to_s
    "#{percent}% #{action_title}"
  end

  # we use GlobalID::Identification so that TransferLocalJob is very simple and knows how to find the object
  # https://dev.mikamai.com/2014/09/01/rails-42-new-gems-active-job-and-global-id/

  def save
    # save has no effect if already persisted because this is in memory
    # if we change the storage, we change this method
    unless persisted?
      # HACK: we use the id as a dom id as well, so it is beneficial to have this be compatible HTML ID
      # if the id doesn't start with a letter, it can cause problems with Bootstrap 4 sometimes
      self.id = 't' + SecureRandom.uuid
      self.status = OodCore::Job::Status.new(state: :queued)
      self.created_at = Time.now.to_i

      self.class.transfers << self
    end
  end

  def cancelable?
    pid && ! completed?
  end

  def cancel
    if status.running? && pid
      Process.kill("TERM", pid)
    end
  end

  def persisted?
    ! id.nil?
  end

  # number of files to copy, move or delete
  def steps
    return @steps if @steps

    names = files.keys.map {|f| File.basename(f)}

    # a move to a different device does a cp then mv
    if action == 'mv' && mv_to_same_device?
      @steps = files.count
    else
      @steps = Files.new.num_files(from, names)
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

  def update_percent(step)
    self.percent = steps == 0 ? 100 : (100.0*((step).to_f/steps)).to_i
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

  def perform_later
    save
    TransferLocalJob.perform_later(self)
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
    action == "mv" && from && to && Files.stat(from)[:dev] == Files.stat(File.dirname(to))[:dev]
  end
end
