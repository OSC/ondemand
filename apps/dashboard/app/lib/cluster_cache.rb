#frozen_string_literal: true

module ClusterCache
  def cluster_options
    Rails.cache.fetch('script_cluster_options', expires_in: 4.hours) do
      cluster_max_cores.map do |cluster_id, max|
        [cluster_id.to_s, cluster_id.to_s, {'data-max-auto-cores': max}]
      end.sort_by { |option| option[0] }
    end
  end

  def cluster_nodes
    Rails.cache.fetch('script_cluster_nodes', expires_in: 4.hours) do 
      {}.tap do |hash|
        batch_clusters.map do |cluster|
          hash[cluster.id] = cluster.job_adapter.nodes
        end
      end
    end
  end

  def cluster_max_cores
    Rails.cache.fetch('script_cluster_max_values', exipres_in: 4.hours) do
      {}.tap do |hash|
        cluster_nodes.each do |cluster_id, nodes|
          hash[cluster_id] = nodes.max { |a, b| a.procs <=> b.procs }.procs
        end
      end
    end
  end

  def batch_clusters
    Rails.cache.fetch('script_batch_clusters', expires_in: 4.hours) do
      Configuration.job_clusters.reject do |c|
        reject_cluster?(c)
      end
    end
  end

  def reject_cluster?(cluster)
    cluster.kubernetes? || cluster.linux_host? || cluster.systemd?
  end
end