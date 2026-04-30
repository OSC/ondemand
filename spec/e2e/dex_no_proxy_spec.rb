require 'spec_helper_e2e'

describe 'OnDemand Dex proxy test' do
  def browser
    @browser ||= new_browser
  end

  before(:all) do
    upload_portal_config('portal_dex_no_proxy.yml')
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
    it { is_expected.to be_listening }
  end

  it 'successfully loads dashboard no path' do
    browser_login(browser)
    browser.goto ctr_base_url
    expect(browser.title).to eq('Dashboard - Open OnDemand')
  end

  it 'has Dex issuer' do
    on hosts, 'curl http://localhost:5556/.well-known/openid-configuration' do |result|
      data = JSON.parse(result.stdout)
      expect(data['issuer']).to eq('http://localhost:5556')
    end
  end
end
