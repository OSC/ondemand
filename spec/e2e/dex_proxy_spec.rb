require 'spec_helper_e2e'

describe 'OnDemand Dex proxy test' do
  def browser
    @browser ||= new_browser
  end

  before(:all) do
    upload_portal_config('portal_dex_proxy.yml')
    update_ood_portal
    restart_apache
    restart_dex
  end

  after(:all) do
    browser.close
  end

  describe port(8080) do
    it { is_expected.to be_listening.on('0.0.0.0').with('tcp') }
  end

  describe port(5556) do
    it { is_expected.to be_listening.on('127.0.0.1').with('tcp') }
  end

  it 'successfully loads dashboard no path' do
    browser_login(browser)
    browser.goto ctr_base_url
    expect(browser.title).to eq('Dashboard - Open OnDemand')
  end

  it 'uses /dex in OIDC issuer' do
    on hosts, 'curl http://localhost:8080/dex/.well-known/openid-configuration' do
      data = JSON.parse(stdout)
      expect(data['issuer']).to eq('http://localhost:8080/dex')
    end
  end
end
