# frozen_string_literal: true

# Helpers for the system status page /dashboard/systemstatus
module SystemStatusHelper
  def title(cluster)
    "#{cluster.metadata.title.titleize} Cluster Status"
  end

  def percent(value, total)
    "#{(value.to_f / total * 100).round 2}%"
  end

  def generic_status(active, total, name)
    free = number_with_delimiter(total - active)
    "#{name} Active: #{number_with_delimiter(active)}/#{number_with_delimiter(total)} (#{free} Free)"
  end

  def node_status(cluster_info)
    generic_status(cluster_info.active_nodes, cluster_info.total_nodes, 'Nodes')
  end

  def node_pct(cluster_info)
    percent(cluster_info.active_nodes, cluster_info.total_nodes)
  end

  def processor_status(cluster_info)
    generic_status(cluster_info.active_processors, cluster_info.total_processors, 'Processors')
  end

  def processor_pct(cluster_info)
    percent(cluster_info.active_processors, cluster_info.total_processors)
  end

  def gpu_status(cluster_info)
    generic_status(cluster_info.active_gpus, cluster_info.total_gpus, 'GPUs')
  end

  def gpu_pct(cluster_info)
    percent(cluster_info.active_gpus, cluster_info.total_gpus)
  end

  def active_jobs(job_adapter)
    job_adapter.info_all_each.select do |info|
      info.status.running?
    end.length
  end

  def active_job_status(job_adapter)
    num_jobs = number_with_delimiter(active_jobs(job_adapter))
    "#{num_jobs} Jobs Running"
  end

  def queued_jobs(job_adapter)
    job_adapter.info_all_each.select do |info|
      info.status.queued?
    end.length
  end

  def queued_job_status(job_adapter)
    num_jobs = number_with_delimiter(queued_jobs(job_adapter))
    "#{num_jobs} Jobs Queued"
  end

  def active_job_pct(job_adapter)
    percent(active_jobs(job_adapter), active_jobs(job_adapter) + queued_jobs(job_adapter))
  end

  def queued_job_pct(job_adapter)
    percent(queued_jobs(job_adapter), active_jobs(job_adapter) + queued_jobs(job_adapter))
  end
end
