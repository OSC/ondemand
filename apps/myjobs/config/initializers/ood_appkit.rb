# config/initializers/ood_appkit.rb

OODClusters = Configuration.clusters

def clusters
  @clusters ||= OodCore::Clusters.new(OodAppkit.clusters.select(&:job_allow?).reject { |c| c.metadata.hidden })
end
