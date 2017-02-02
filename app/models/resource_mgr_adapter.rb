# Class that implements the same interface as OSC::Machete::TorqueHelper
# but uses ood_job gem to interface with resource managers

# OodJob errors will be caught and re-raised as PBS::Error objects
class ResourceMgrAdapter

  def cluster_for_host_id(host)
    raise PBS::Error, "host nil" if host.nil?
    raise PBS::Error, "host is invalid value: #{host}" unless OODClusters.has_key?(host.to_sym)

    OODClusters[host.to_sym]
  end

  def adapter
    OodJob::Adapters::Torque
  end

  # TODO: this adapter could ignore the host argument and use the one that is
  # specified when it is instantiated.

  # returns job id
  def qsub(script_path, host: nil, depends_on: {}, account_string: nil)
    cluster = cluster_for_host_id(host)
    script = OodJob::Script.new(content: script_path, accounting_id: account_string)

    adapter.new(cluster: cluster).submit(script: script, **depends_on)

  rescue OodJob::Adapter::Error => e
    raise PBS::Error, e.message
  end

  def qstat(id, host: nil)
    cluster = cluster_for_host_id(host)
    status = adapter.new(cluster: cluster).status(id: id)

    # convert OodJobStatus to OSC::Machete::Status
    status_for_ood_job_status(status)
  end

  def status_for_ood_job_status(status)
    case status.to_sym
    when :undetermined, nil
      OSC::Machete::Status.passed
    when :queued
      OSC::Machete::Status.queued
    when :queued_held
      OSC::Machete::Status.held
    else
      # all other statuses considerd "running"
      OSC::Machete::Status.running
    end
  end
end
