# config/initializers/ood_appkit.rb
require "ood_core"

OodAppkit.configure do |config|
  config.clusters = OodCore::Clusters.new(
      OodCore::Clusters.load_file(ENV['OOD_CLUSTERS'] || '/etc/ood/config/clusters.d').select(&:job_allow?)
  )
end

OODClusters = OodAppkit.clusters
