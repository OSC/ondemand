# config/initializers/ood_appkit.rb

OODClusters = OodAppkit.clusters.hpc.reject{|k,v| !v.resource_mgr_server?}
