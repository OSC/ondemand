# frozen_string_literal: true

class HpcJob < OodCore::Job::Info
  attr_reader :cluster

  COMPLETED = 'completed'

  class << self
    def from_core_info(info: nil, cluster: nil)
      new(cluster: cluster, **info.to_h)
    end
  end

  def initialize(cluster: nil, **args)
    @cluster = cluster
    super(**args)
  end

  def completed?
    status.to_s == COMPLETED
  end

  def to_h
    super.to_h.merge({ cluster:         cluster,
                       status:          status.to_s,
                       allocated_nodes: [] }).deep_stringify_keys
  end
end
