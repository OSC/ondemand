# frozen_string_literal: true

# helper for the system status page
module SystemStatusHelper
  # Used to not repeatedly request the job adapter
  def update_cluster(cluster)
    @job_adapter = cluster.job_adapter
    @cluster_info = @job_adapter.cluster_info
    @cluster = cluster
  end

  def job_adapter(cluster)
    if @cluster != cluster
      update_cluster(cluster)
    end

    @job_adapter
  end

  def cluster_info(cluster)
    if @cluster != cluster
      update_cluster(cluster)
    end

    @cluster_info
  end

  def title(cluster)
    "#{cluster.metadata.title.titleize} Cluster Status"
  end

  def generic_pct(value, total)
    "#{(value.to_f / total * 100).round 2}%"
  end

  def generic_status(active, total, name)
    "#{active} of #{total} #{name} Active (#{total - active} Free)"
  end

  def node_status(cluster)
    c_info = cluster_info(cluster)
    generic_status(c_info.active_nodes, c_info.total_nodes, 'Nodes')
  end

  def node_pct(cluster)
    c_info = cluster_info(cluster)
    generic_pct(c_info.active_nodes, c_info.total_nodes)
  end

  def processor_status(cluster)
    c_info = cluster_info(cluster)
    generic_status(c_info.active_processors, c_info.total_processors, 'Processors')
  end

  def processor_pct(cluster)
    c_info = cluster_info(cluster)
    generic_pct(c_info.active_processors, c_info.total_processors)
  end

  def gpu_status(cluster)
    c_info = cluster_info(cluster)
    generic_status(c_info.active_gpus, c_info.total_gpus, 'GPUs')
  end

  def gpu_pct(cluster)
    c_info = cluster_info(cluster)
    generic_pct(c_info.active_gpus, c_info.total_gpus)
  end

  def active_jobs(cluster)
    active_count = 0
    job_adapter(cluster).info_all_each do |i|
      if i.status.running?
        active_count += 1
      end
    end
    active_count
  end

  def active_job_status(cluster)
    "#{active_jobs cluster} Jobs Running"
  end

  def queued_jobs(cluster)
    queued_count = 0
    job_adapter(cluster).info_all_each do |i|
      if i.status.queued?
        queued_count += 1
      end
    end
    queued_count
  end

  def queued_job_status(cluster)
    "#{queued_jobs(cluster)} Jobs Queued"
  end

  def active_job_pct(cluster)
    generic_pct(active_jobs(cluster), active_jobs(cluster) + queued_jobs(cluster))
  end

  def queued_job_pct(cluster)
    generic_pct(queued_jobs(cluster), active_jobs(cluster) + queued_jobs(cluster))
  end
end
