# frozen_string_literal: true

class HpcJob < OodCore::Job::Info
  include ActionView::Helpers::DateHelper

  attr_reader :cluster

  COMPLETED = 'completed'

  class << self
    def from_core_info(info: nil, cluster: nil)
      new(cluster: cluster, **info.to_h)
    end
  end

  def initialize(**args)
    args = args.deep_symbolize_keys
    @cluster = args[:cluster]
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

  def to_human_display
    to_h.reject do |key, _value|
      key == 'native'
    end.map do |key, value|
      if ['wallclock_time', 'wallclock_limit'].include?(key)
        [key, fix_time(value)]
      else
        [key, value]
      end
    end.to_h.transform_keys(&:humanize).compact_blank
  end

  def fix_time(time)
    distance_of_time_in_words(time, 0, false, :only => [:minutes, :hours], :accumulate_on => :hours)
  end
end
