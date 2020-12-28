class TransferLocalJob < ApplicationJob
  queue_as :default

  # job_id vs provider_job_id?
  Progress = Struct.new(:id, :status, :percent, :message, :cancelable, :data, :exit_status)

  class << self
    attr_writer :progress

    def progress
      @progress ||= {}
    end

    def cancel(id)
      if progress[id] && progress[id].status.running? && progress[id].data
        Process.kill("TERM", progress[id].data)
      end
    end
  end

  def progress
    self.class.progress[job_id] ||= Progress.new(
      job_id,
      OodCore::Job::Status.new(state: :queued)
    )
  end

  after_enqueue do |job|
    # this will init with queue
    job.progress
  end

  around_perform do |job, block|
    job.progress.status = OodCore::Job::Status.new(state: :running)
    block.call
    job.progress.status = OodCore::Job::Status.new(state: :completed)
  end

  def perform(action, from, names, to=nil)
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
      progress.data = t.pid
      progress.cancelable = true

      err_reader = Thread.new { e.read  }

      o.each_line.with_index do |l, index|
        # percent complete
        progress.percent = (100.0*(index.to_f/steps)).to_i
      end
      o.close

      # FIXME: did it fail? need fail status?
      progress.exit_status = t.value.exitstatus
      progress.message = err_reader.value
    end
  end
end
