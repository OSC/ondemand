# config/initializers/ood_appkit.rb

OODClusters = OodAppkit.clusters.select do |c|
  c.valid? && c.hpc_cluster? && c.resource_mgr_server? && c.resource_mgr_server.is_a?(OodCluster::Servers::Torque)
end.each_with_object({}) { |c, h| h[c.id] = c }

# the controller will update status manually
OscMacheteRails.update_status_of_all_active_jobs_on_each_request = false
