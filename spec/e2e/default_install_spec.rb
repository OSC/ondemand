# frozen_string_literal: true

require 'spec_helper_e2e'

describe 'Default install' do
  def browser
    @browser ||= new_browser
  end

  before(:all) do
    upload_portal_config('empty.yml')
    update_ood_portal
    restart_apache
  end

  describe file(host_portal_config) do
    it { is_expected.to be_file }

    expected = File.join(proj_root, 'ood-portal-generator/spec/fixtures/ood-portal.conf.default')
    its(:content) { is_expected.to eq(File.read(expected)) }
  end

  describe 'default webpage' do
    it 'is the only page' do
      [
        '/', '/anywhere', '/public/maintenance/index.html',
        '/pun/sys/dashboard', '/nginx/init'
      ].each do |page|
        curl_on(hosts, "-L localhost#{page}") do |result|
          expect(result.stdout).to eq(File.read("#{proj_root}/ood-portal-generator/share/need_auth.html"))
        end
      end
    end
  end
end
