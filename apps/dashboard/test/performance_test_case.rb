# frozen_string_literal: true

require 'test_helper'
require 'rails/performance_test_help'

class PerformanceTestCase < ActionDispatch::PerformanceTest
  def self.runs
    return 25 if ENV['OOD_BENCHMARK_RUNS'].nil?

    ENV['OOD_BENCHMARK_RUNS'].to_i
  end

  self.profile_options = {
    runs: runs, metrics: [:wall_time, :process_time, :memory, :objects],
    output: 'tmp/performance', formats: [:graph_html, :call_tree, :call_stack]
  }
end
