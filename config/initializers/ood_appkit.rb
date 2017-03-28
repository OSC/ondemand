# config/initializers/ood_appkit.rb
require "ood_core"

OodAppkit.configure do |config|
  config.clusters = OodCore::Clusters.new(
      OodCore::Clusters.load_file("/etc/ood/config/clusters.d").select(&:job_allow?)
  )
end

#OODClusters = OodAppkit.clusters.select do |c|
#  c.valid? &&
#    c.resource_mgr_server? &&
#    c.resource_mgr_server.is_a?(OodCluster::Servers::Torque)
#end.each_with_object({}) { |c, h| h[c.id] = c }

OODClusters = OodAppkit.clusters
