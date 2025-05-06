require 'spec_helper_e2e'

describe 'OnDemand browser test' do
  def browser
    @browser ||= new_browser
  end

  before(:all) do
    browser_login(browser)
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
    browser.goto ctr_base_url
    expect(browser.title).to eq('Dashboard - Open OnDemand')
  end

  it 'uses /dex in OIDC issuer' do
    on hosts, 'curl http://localhost:8080/dex/.well-known/openid-configuration' do
      data = JSON.parse(result.stdout)
      expect(data['issuer']).to eq('http://localhost:8080/dex')
    end
  end

  it 'succesfully redirects /pun/sys/activejobs' do
    browser.goto "#{ctr_base_url}/pun/sys/activejobs"
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard/activejobs")
    expect(browser.title).to eq('Dashboard - Open OnDemand')
    expect(browser.table(id: 'job_status_table').present?).to be true
  end

  it 'redirects from /pun/sys/activejobs and preserves query params' do
    browser.goto "#{ctr_base_url}/pun/sys/activejobs?jobcluster=all&jobfilter=all"
    browser.screenshot.save 'activejobs.png'
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard/activejobs?jobcluster=all&jobfilter=all")
    expect(browser.title).to eq('Dashboard - Open OnDemand')
    expect(browser.table(id: 'job_status_table').present?).to be true
  end

  it 'redirects /pun/sys/file-editor#index' do
    browser.goto "#{ctr_base_url}/pun/sys/file-editor"
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard/files/fs/home/ood")
    expect(browser.title).to eq('Dashboard - Open OnDemand')
    expect(browser.table(id: 'directory-contents').present?).to be true
  end

  it 'redirects /pun/sys/file-editor and preserves the file' do
    browser.goto "#{ctr_base_url}/pun/sys/file-editor/edit/home/ood/.bashrc"
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard/files/edit/fs/home/ood/.bashrc")
    expect(browser.title).to eq('File Editor - Open OnDemand - .bashrc')
  end

  it 'redirects /pun/sys/files#index' do
    browser.goto "#{ctr_base_url}/pun/sys/files"
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard/files/fs/home/ood")
    sleep 5
    expect(browser.title).to eq('Dashboard - Open OnDemand')
    expect(browser.table(id: 'directory-contents').present?).to be true
  end

  it 'redirects /pun/sys/files and preserves the path' do
    browser.goto "#{ctr_base_url}/pun/sys/files/fs/var/www/ood"
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard/files/fs/var/www/ood")
    expect(browser.title).to eq('Dashboard - Open OnDemand')
    expect(browser.table(id: 'directory-contents').present?).to be true
  end
end
