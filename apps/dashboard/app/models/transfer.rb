class Transfer
  include ActiveModel::Model
  include GlobalID::Identification

  # for progress tracking and retrieval
  attr_accessor :id, :status, :created_at, :completed_at, :percent

  # error reporting (use different tool?)
  attr_accessor :exit_status, :message

  attr_accessor :pid

  #TODO: change
  attr_accessor :action, :from, :names, :to

  class << self
    def transfers
      @transfers ||= []
    end

    def find(id)
      transfers.find {|t| t.id == id }
    end
  end

  #FIXME: So one idea here was to create a generic transfer object
  # that was used to render the view
  # and that this was the generic transfer object:
  #
  # Progress = Struct.new(:id, :status, :action, :from, :names, :to, :created_at, :completed_at, :percent, :message, :cancelable, :data, :exit_status, keyword_init: true
  #
  # lets abstract later after we add OneDrive or Globus
  # especially since we might not have percent but just busy signal

  # TODO:
  # def submit
  #   if synchronous?
  #     perform
  #   else
  #     TransferLocalJob.perform_later(self)
  #   end
  # end
  #
  # include GlobalID::Identification
  #
  # def self.find(id)
  # end
  #
  # and
  #
  # id
  #
  # https://dev.mikamai.com/2014/09/01/rails-42-new-gems-active-job-and-global-id/
  # PORO class example
  def save
    # save has no effect if already persisted because this is in memory
    # if we change the storage, we change this method
    unless persisted?
      self.id = SecureRandom.uuid
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

  def perform
    self.status = OodCore::Job::Status.new(state: :running)

    # FIXME: wanted to use separate functions but then we can't set the pid
    # unless we execute popen3 without a block
    #
    # FIXME: logging of ACTIONS

    # number of files to copy, move or delete
    steps = Files.new.num_files(from, names)

    args = [action.to_s, '-v']

    if action == 'mv'
      steps *= 2
    else
      args << '-r'
    end

    args += names
    args << to if to

    # FIXME: validation :-P
    Open3.popen3(*args, chdir: from) do |i, o, e, t|
      self.pid = t.pid

      err_reader = Thread.new { e.read  }

      o.each_line.with_index do |l, index|
        #FIXME: slice(?).last so that we only update progress a few times per...

        # percent complete
        self.percent = (100.0*((index+1).to_f/steps)).to_i
      end
      o.close

      # FIXME: did it fail? need fail status?
      self.exit_status = t.value
      self.message = err_reader.value
      self.completed_at = Time.now.to_i

      self
    end
  ensure
    self.status = OodCore::Job::Status.new(state: :completed)
  end

  def synchronous?
    action == "mv" && Files.stat(from)[:dev] == Files.stat(File.dirname(to))[:dev]
  end
end