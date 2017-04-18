# config/initializers/ood_appkit.rb

OODClusters = OodCore::Clusters.new(
  OodAppkit.clusters.select(&:job_allow?).reject { |c| c.metadata.hidden }
)
