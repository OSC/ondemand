class SystemStatusController < ApplicationController
  def index
    @job_clusters = OodAppkit.clusters
                             .select(&:job_allow?)
                             .reject { |c| c.metadata.hidden }
  end
end
