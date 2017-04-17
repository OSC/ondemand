# config/initializers/ood_appkit.rb
require "ood_core"

OODClusters = OodCore::Clusters.new(
  OodAppkit.clusters.select(&:job_allow?)
)
