# frozen_string_literal: true

require 'test_helper'

class ActiveJobsHelperTest < ActionView::TestCase
  include ActiveJobsHelper

  def clusters
    OodCore::Clusters.load_file('test/fixtures/config/clusters.d')
  end

  def setup
    OODClusters.stubs(:[]).with('owens').returns(clusters['owens'])
    OODClusters.stubs(:[]).with('oakley').returns(clusters['oakley'])
    OODClusters.stubs(:[]).with('quick').returns(clusters['quick'])
    OODClusters.stubs(:[]).with(nil).returns(clusters[nil])
    OODClusters.stubs(:[]).with('').returns(clusters[''])
  end

  test 'generates ganglia cpu image URL' do
    expected_url = 'https://ganglia.osc.edu/graph.php?c=Owens&z=small&cs=9&g=cpu_report&h=r0001.ten.osc.edu'
    assert_equal expected_url, build_ganglia_link('owens', '9', 'cpu_report', 'r0001', 'small')
  end

  test 'grafana grafana cpu panel URL' do
    expected_url = 'https://grafana.osc.edu/d-solo/aaba6Ahbauquag/ondemand-clusters/?orgId=1&theme=light&from=1582303423000&to=now&var-cluster=owens&var-host=o0484&panelId=20&var-jobid=9427651'
    assert_equal expected_url, build_grafana_link('owens', '1582303423', 'cpu', 'o0484', '9427651')
  end

  test 'generates grafana memory panel URL' do
    expected_url = 'https://grafana.osc.edu/d-solo/aaba6Ahbauquag/ondemand-clusters/?orgId=1&theme=light&from=1582303423000&to=now&var-cluster=owens&var-host=o0484&panelId=24&var-jobid=9427651'
    assert_equal expected_url, build_grafana_link('owens', '1582303423', 'memory', 'o0484', '9427651')
  end

  test 'generates grafana node dashboard URL' do
    expected_url = 'https://grafana.osc.edu/d/aaba6Ahbauquag/ondemand-clusters/?orgId=1&theme=light&from=1582303423000&to=now&var-cluster=owens&var-host=o0484'
    assert_equal expected_url, build_grafana_link('owens', '1582303423', 'node', 'o0484')
  end

  test 'generates grafana job dashboard URL' do
    expected_url = 'https://grafana.osc.edu/d/aaba6Ahbauquag/ondemand-clusters/?orgId=1&theme=light&from=1582303423000&to=now&var-cluster=owens&var-host=o0484&var-jobid=9427651'
    assert_equal expected_url, build_grafana_link('owens', '1582303423', 'job', 'o0484', '9427651')
  end

  test 'respects ganglia settings' do
    assert_equal true, has_ganglia('owens') && clusters['owens'].present?
    assert_equal true, has_ganglia('oakley') && clusters['oakley'].present?
    assert_equal false, has_grafana(nil)
    assert_equal false, has_grafana(nil.to_s)
  end

  test 'respects grafana settings' do
    assert_equal true, has_grafana('owens') && clusters['owens'].present?
    assert_equal true, clusters['owens'].present? # just to be sure the next has_grafana checks this
    assert_equal false, has_grafana('oakley')
    assert_equal false, has_grafana(nil)
    assert_equal false, has_grafana(nil.to_s)
  end
end
