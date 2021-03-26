# Hacks for the activejobs app
# Filter = ActiveJobs::Filter

# same definition as ApplicationHelper.clusters
OODClusters = OodCore::Clusters.new(OodAppkit.clusters.select(&:allow?).reject { |c| c.metadata.hidden })