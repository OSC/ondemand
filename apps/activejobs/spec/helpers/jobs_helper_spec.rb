require 'rails_helper'

RSpec.describe JobsHelper, type: :helper do
  describe 'build_ganglia_link' do
    it 'generates cpu image URL' do
      expected_url = "https://ganglia.domain/graph.php?c=Ruby&z=small&cs=9&g=cpu_report&h=r0001.domain"
      expect(build_ganglia_link('ruby', '9', 'cpu_report', 'r0001', 'small')).to eq(expected_url)
    end
  end
  describe 'build_grafana_link' do
    it 'generates cpu panel URL' do
      expected_url = "https://grafana.domain/d-solo/aaba6Ahbauquag/ondemand-clusters/?orgId=3&theme=light&from=1582303423000&to=now&var-cluster=owens&var-host=o0484&panelId=20&var-jobid=9427651"
      expect(build_grafana_link('owens', '1582303423', 'cpu', 'o0484', '9427651')).to eq(expected_url)
    end

    it 'generates memory panel URL' do
      expected_url = "https://grafana.domain/d-solo/aaba6Ahbauquag/ondemand-clusters/?orgId=3&theme=light&from=1582303423000&to=now&var-cluster=owens&var-host=o0484&panelId=24&var-jobid=9427651"
      expect(build_grafana_link('owens', '1582303423', 'memory', 'o0484', '9427651')).to eq(expected_url)
    end

    it 'generates node dashboard URL' do
      expected_url = "https://grafana.domain/d/aaba6Ahbauquag/ondemand-clusters/?orgId=3&theme=light&from=1582303423000&to=now&var-cluster=owens&var-host=o0484"
      expect(build_grafana_link('owens', '1582303423', 'node', 'o0484')).to eq(expected_url)
    end

    it 'generates job dashboard URL' do
      expected_url = "https://grafana.domain/d/aaba6Ahbauquag/ondemand-clusters/?orgId=3&theme=light&from=1582303423000&to=now&var-cluster=owens&var-host=o0484&var-jobid=9427651"
      expect(build_grafana_link('owens', '1582303423', 'job', 'o0484', '9427651')).to eq(expected_url)
    end
  end

  describe 'has_ganglia' do
    it 'does not have ganglia' do
      expect(has_ganglia('owens')).to eq(false)
    end
    it 'has ganglia' do
      expect(has_ganglia('ruby')).to eq(true)
    end
  end

  describe 'has_grafana' do
    it 'has grafana' do
      expect(has_grafana('owens')).to eq(true)
    end
    it 'does not have grafana' do
      expect(has_grafana('ruby')).to eq(false)
    end
  end
end
