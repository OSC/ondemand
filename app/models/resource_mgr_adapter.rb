# Class that implements the same interface as OSC::Machete::TorqueHelper
# but uses ood_job gem to interface with resource managers

# OodJob errors will be caught and re-raised as PBS::Error objects
class ResourceMgrAdapter

  attr_reader :workflow

  def initialize(workflow)
    @workflow = workflow
  end

  # TODO: this adapter could ignore the host argument and use the one that is
  # specified when it is instantiated.

  # returns job id
  def qsub(script_path, host: nil, depends_on: {}, account_string: nil)
    # FIXME: WARNING!!! BY THE TIME THAT THIS METHOD IS CALLED osc-machete HAS
    # ALREADY CHECKED FOR THE EXISTENCE OF shell script
    # ood_job now expects an IO object that responds to read OR a string to get
    # the script content. It does not check for the existence of this file
    # THIS IS REDUNDANT CHECK so we remember to do this when moving away from
    # machete
    #
    # the current directory is now the job directory
    # current_directory but script_path is a STRING and relative
    script_path = Pathname.new(script_path)
    raise OSC::Machete::Job::ScriptMissingError, "#{script_path} does not exist or cannot be read" unless script_path.file? && script_path.readable?

    cluster = cluster_for_host_id(host)
    script = OodCore::Job::Script.new(
      content: script_path.read,
      accounting_id: account_string,
      job_array_request: workflow.job_array_request.presence
    )
    adapter(cluster).submit( script, **depends_on)

  rescue OodCore::JobAdapterError => e
    raise PBS::Error, e.message
  end

  def qstat(id, host: nil)
    cluster = cluster_for_host_id(host)
    status = adapter(cluster).status(id)

    # convert OodJobStatus to OSC::Machete::Status
    status_for_ood_job_status(status)

  rescue OodCore::JobAdapterError => e
    raise PBS::Error, e.message
  end

  def qdel(id, host: nil)
    cluster = cluster_for_host_id(host)
    adapter(cluster).delete(id)

  rescue OodCore::JobAdapterError => e
    raise PBS::Error, e.message
  end

  private

  def cluster_for_host_id(host)
    raise PBS::Error, "host nil" if host.nil?
    raise PBS::Error, "host is invalid value: #{host}" unless OODClusters[host.to_sym]

    OODClusters[host.to_sym]
  end

  def adapter(cluster)
    cluster.job_adapter
  end

  # Returns an OSC::Machete::Status object from an OodJob::Status object
  #
  # @param [OodJob::Status] status An OodJob::Status object
  # @return [OSC::Machete::Status] An OSC::Machete object representing the status
  def status_for_ood_job_status(status)
    case status.to_sym
      when :completed
        OSC::Machete::Status.passed
      when :queued
        OSC::Machete::Status.queued
      when :queued_held
        OSC::Machete::Status.held
      when :suspended
        OSC::Machete::Status.suspended
      when :running
        OSC::Machete::Status.running
      else
        OSC::Machete::Status.undetermined
    end
  end
end
