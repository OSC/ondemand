# frozen_string_literal: true

require 'spec_helper_e2e'

describe 'Pun Pre Hook' do
  def browser
    @browser ||= new_browser
  end

  before(:all) do
    on hosts, '/opt/ood/nginx_stage/sbin/nginx_stage nginx_clean --force'
    on hosts, 'mkdir -p /opt/hooks'
    upload_portal_config('portal_with_prehook.yml')
    update_ood_portal
    restart_apache
    restart_dex
  end

  after do
    browser.close
    on hosts, '/opt/ood/nginx_stage/sbin/nginx_stage nginx_clean --force'
  end

  context 'pre hook crash' do
    before(:all) do
      scp_to(hosts, hook_fixture('bad_pre_hook'), '/opt/hooks/pun_pre_hook')
    end

    it 'does not crash login when pre hook crashes' do
      browser_login(browser)
      browser.goto ctr_base_url
      expect(browser.title).to eq('Dashboard - Open OnDemand')
    end

    describe file('/tmp/hook.out') do
      its(:content) { is_expected.to contain '/opt/hooks/pun_pre_hook: line 4: wont_find_cmd: command not found' }
    end
  end

  context 'missing pre hook' do
    before(:all) do
      on hosts, 'rm -f /opt/hooks/pun_pre_hook'
    end

    it 'does not crash login when pre hook is misconfigured' do
      browser_login(browser)
      browser.goto ctr_base_url
      expect(browser.title).to eq('Dashboard - Open OnDemand')
    end
  end

  context 'environment variables' do
    before(:all) do
      scp_to(hosts, hook_fixture('good_pre_hook'), '/opt/hooks/pun_pre_hook')
    end

    it 'does not crash login when pre hook crashes' do
      browser_login(browser)
      browser.goto ctr_base_url
      expect(browser.title).to eq('Dashboard - Open OnDemand')
    end

    describe file('/tmp/hook.out') do
      its(:content) { is_expected.to contain "input args are --user ood\naccess token set\nemail claim set\n" }
    end
  end
end
