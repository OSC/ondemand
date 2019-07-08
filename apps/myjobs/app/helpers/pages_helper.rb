module PagesHelper

  # Return the title of the workflow cluster or the titleized key
  #
  # @return [String, nil] The title of the cluster or nil if unassigned
  def cluster_title(cluster_key)
    if cluster_key && OODClusters[cluster_key]
      OODClusters[cluster_key].metadata.title ||  cluster_key.titleize
    end
  end
end
