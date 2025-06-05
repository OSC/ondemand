# frozen_string_literal: true

class ModuleBrowserController < ApplicationController
  def index
    # FIXME: select clusters from Configuration.job_clusters
    @clusters = OodAppkit.clusters.select(&:job_allow?).reject { |c| c.metadata.hidden }
    @modules = HpcModule.all.group_by(&:name).sort_by { |name, _| name.to_s.titleize }
    @modules_last_updated = helpers.modules_last_updated
  end
end
