# frozen_string_literal: true

require 'test_helper'

class AccountCacheTest < ActiveSupport::TestCase
  class CacheHelper
    extend AccountCache
  end

  def setup
    Rails.cache.clear
  end

  def gpu_queue
    OodCore::Job::QueueInfo.new(
      name: 'gpu',
      tres: { 'cpu' => '56', 'node' => '2', 'gres/gpu' => '4', 'gres/gpu:v100' => '4' }
    )
  end

  def typed_gpu_queue
    OodCore::Job::QueueInfo.new(
      name: 'gpu-quad',
      tres: { 'cpu' => '48', 'node' => '2', 'gres/gpu' => '8', 'gres/gpu:v100-quad' => '8' }
    )
  end

  def cpu_queue
    OodCore::Job::QueueInfo.new(
      name: 'serial',
      tres: { 'cpu' => '40', 'node' => '10' }
    )
  end

  test 'queue_gpu_data hides auto gpu fields for non-gpu queues' do
    data = CacheHelper.send(:queue_gpu_data, cpu_queue)

    assert_equal true, data['data-hide-auto-gpus']
    assert_equal true, data['data-hide-auto-gpu-type']
    assert_nil data['data-max-auto-gpus']
  end

  test 'queue_gpu_data sets min max for gpu queues' do
    data = CacheHelper.send(:queue_gpu_data, gpu_queue)

    assert_nil data['data-hide-auto-gpus']
    assert_equal 1, data['data-min-auto-gpus']
    assert_equal 2, data['data-max-auto-gpus']
    assert_nil data['data-hide-auto-gpu-type']
  end

  test 'queue_gpu_data hides auto_gpu_type when queue has untyped gpus only' do
    queue = OodCore::Job::QueueInfo.new(
      name: 'gpu-any',
      tres: { 'node' => '4', 'gres/gpu' => '4' }
    )
    data = CacheHelper.send(:queue_gpu_data, queue)

    assert_equal 1, data['data-max-auto-gpus']
    assert_equal true, data['data-hide-auto-gpu-type']
  end

  test 'max_gpus_for uses partition gpu total when node count is missing' do
    queue = OodCore::Job::QueueInfo.new(
      name: 'gpu',
      tres: { 'gres/gpu' => '6', 'gres/gpu:a100' => '6' }
    )

    assert_equal 6, CacheHelper.send(:max_gpus_for, queue)
  end

  test 'gpu_types filters types by queue availability' do
    CacheHelper.stubs(:accounts).returns(
      [OodCore::Job::AccountInfo.new(name: 'pzs0714', cluster: 'owens')]
    )
    CacheHelper.stubs(:queues_per_cluster).returns(
      {
        owens: [gpu_queue, typed_gpu_queue, cpu_queue]
      }
    )

    options = CacheHelper.gpu_types
    types = options.map(&:first)

    assert_equal ['v100', 'v100-quad'], types

    v100 = options.find { |opt| opt.first == 'v100' }.last
    assert_equal false, v100['data-option-for-auto-queues-gpu-quad']
    assert_equal false, v100['data-option-for-auto-queues-serial']
    assert_nil v100['data-option-for-auto-queues-gpu']

    quad = options.find { |opt| opt.first == 'v100-quad' }.last
    assert_equal false, quad['data-option-for-auto-queues-gpu']
    assert_equal false, quad['data-option-for-auto-queues-serial']
    assert_nil quad['data-option-for-auto-queues-gpu-quad']
  end

  test 'queues merge gpu data into options' do
    CacheHelper.stubs(:accounts).returns(
      [OodCore::Job::AccountInfo.new(name: 'pzs0714', cluster: 'owens')]
    )
    CacheHelper.stubs(:queues_per_cluster).returns(
      {
        owens: [gpu_queue, cpu_queue]
      }
    )

    options = CacheHelper.queues
    gpu_opt = options.find { |opt| opt.first == 'gpu' }
    cpu_opt = options.find { |opt| opt.first == 'serial' }

    assert_equal 2, gpu_opt.last['data-max-auto-gpus']
    assert_equal 1, gpu_opt.last['data-min-auto-gpus']
    assert_equal true, cpu_opt.last['data-hide-auto-gpus']
    assert_equal true, cpu_opt.last['data-hide-auto-gpu-type']
  end
end
