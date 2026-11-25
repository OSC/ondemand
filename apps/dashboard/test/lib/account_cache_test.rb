# frozen_string_literal: true

require 'test_helper'
require 'smart_attributes'

class AccountCacheTest < ActiveSupport::TestCase
  test 'queues emit floored-hour clamp data for queues with finite max_time' do
    Rails.cache.clear
    queue_stubs = [
      stub(name: 'short',     max_time: 3600,       allow_qos: [], deny_qos: [], allow_accounts: nil, deny_accounts: []),
      stub(name: 'long',      max_time: 7 * 86_400, allow_qos: [], deny_qos: [], allow_accounts: nil, deny_accounts: []),
      stub(name: 'unlimited', max_time: nil,        allow_qos: [], deny_qos: [], allow_accounts: nil, deny_accounts: []),
      stub(name: 'oddfloor',  max_time: 7199,       allow_qos: [], deny_qos: [], allow_accounts: nil, deny_accounts: [])
    ]
    Configuration.stubs(:job_clusters).returns([stub(id: 'owens')])
    SmartAttributes::AttributeFactory.stubs(:queues_per_cluster).returns('owens' => queue_stubs)
    SmartAttributes::AttributeFactory.stubs(:accounts).returns(
      [stub(name: 'u1', cluster: 'owens', to_s: 'u1', qos: [])]
    )

    tuples = SmartAttributes::AttributeFactory.queues

    short_data     = tuples.find { |t| t[0] == 'short'     }&.last
    long_data      = tuples.find { |t| t[0] == 'long'      }&.last
    unlimited_data = tuples.find { |t| t[0] == 'unlimited' }&.last
    oddfloor_data  = tuples.find { |t| t[0] == 'oddfloor'  }&.last

    assert_equal 1,   short_data['data-max-auto-wallclock-limit-for-auto-queues-short']
    assert_equal 168, long_data['data-max-auto-wallclock-limit-for-auto-queues-long']
    refute unlimited_data.keys.any? { |k| k.start_with?('data-max-auto-wallclock-limit-for-auto-queues-') }
    assert_equal 1,   oddfloor_data['data-max-auto-wallclock-limit-for-auto-queues-oddfloor']
  end
end
