# frozen_string_literal: true

class ModuleBrowserController < ApplicationController
  def index
    # FIXME: select clusters from Configuration.job_clusters
    @clusters = OodAppkit.clusters.select(&:job_allow?).reject { |c| c.metadata.hidden }
    @selected_clusters = params[:cluster]
    @modules = @clusters.flat_map do |cluster|
      HpcModule.all(cluster.id).each { |mod| mod.cluster = cluster.id }
    end
    @modules = @modules.group_by(&:name)
  end
end
