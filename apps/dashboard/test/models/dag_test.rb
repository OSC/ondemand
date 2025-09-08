# frozen_string_literal: true

require 'test_helper'

class WorkflowTest < ActiveSupport::TestCase
  def setup
    stub_sinfo
  end

  # a -> b -> c
  test 'test linear graph' do
    attributes = {
      launcher_ids: ["a", "b", "c"],
      source_ids:   ["a", "b"],
      target_ids:   ["b", "c"]
    }
    dependency =   { "b"=>["a"], "c"=>["b"] }
    order = ["a", "b", "c"]
    
    graph = Dag.new(attributes)
    refute graph.has_cycle

    assert_equal(dependency, graph.dependency)
    assert_equal(order, graph.order)
  end

  # b; a -> a
  test 'test self loop failure' do
    attributes = {
      launcher_ids: ["a", "b"],
      source_ids:   ["a"],
      target_ids:   ["a"]
    }
    graph = Dag.new(attributes)
    assert graph.has_cycle
  end

  # a -> b -> c -> a
  test 'test cycle failure' do
    attributes = {
      launcher_ids: ["a", "b", "c"],
      source_ids:   ["a", "b", "c"],
      target_ids:   ["b", "c", "a"]
    }
    graph = Dag.new(attributes)
    assert graph.has_cycle
  end

  # a -> b -> c
  #  \       /
  #   d -> e
  test 'test cross edge' do
    attributes = {
      launcher_ids: ["a", "b", "c", "d", "e"],
      source_ids:   ["a", "b", "a", "d", "e"],
      target_ids:   ["b", "c", "d", "e", "c"]
    }
    dependency =   { "b"=>["a"], "c"=>["b", "e"], "d"=>["a"], "e"=>["d"] }
    order = ["a", "d", "e", "b", "c"]
    
    graph = Dag.new(attributes)
    refute graph.has_cycle

    assert_equal(dependency, graph.dependency)
    assert_equal(order, graph.order)
  end

  # a -> b
  #  \ /  \   *all pointing down
  #   c -> d
  test 'test forward edge' do
    attributes = {
      launcher_ids: ["a", "b", "c", "d"],
      source_ids:   ["a", "a", "b", "b", "c"],
      target_ids:   ["b", "c", "c", "d", "d"]
    }
    dependency =   { "b"=>["a"], "c"=>["a", "b"], "d"=>["b", "c"] }
    order = ["a", "b", "c", "d"]
    
    graph = Dag.new(attributes)
    refute graph.has_cycle

    assert_equal(dependency, graph.dependency)
    assert_equal(order, graph.order)
  end

end
