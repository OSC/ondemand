# frozen_string_literal: true

class ModuleBrowserController < ApplicationController
  def index
    # FIXME: select clusters from Configuration.job_clusters
    @clusters = OodAppkit.clusters.select(&:job_allow?).reject { |c| c.metadata.hidden }
    # TODO:  Modify HpcModule to return all modules across all clusters
    @modules = @clusters.flat_map do |cluster|
      HpcModule.all(cluster.id).each { |mod| mod.cluster = cluster.id }
    end
    @modules = @modules.group_by(&:name)
    @modules_last_updated = helpers.modules_last_updated
  end
end
