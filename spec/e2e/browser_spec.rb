# frozen_string_literal: true

require 'spec_helper_e2e'

describe 'OnDemand browser test' do
  def browser
    @browser ||= new_browser
  end

  def wait_for_page(title:, url: nil, table_id: nil)
    message = proc do
      "Expected URL #{url || '(any)'}, title #{title.inspect}, table #{table_id || '(none)'}; " \
        "got URL #{browser.url}, title #{browser.title.inspect}"
    end

    Watir::Wait.until(timeout: 30, interval: 0.25, message: message) do
      (url.nil? || browser.url == url) &&
        (title.is_a?(Regexp) ? title.match?(browser.title) : browser.title == title) &&
        (table_id.nil? || browser.table(id: table_id).present?)
    end
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
    wait_for_page(title: 'Dashboard - Open OnDemand')
    expect(browser.title).to eq('Dashboard - Open OnDemand')
  end

  it 'uses /dex in OIDC issuer' do
    on hosts, 'curl http://localhost:8080/dex/.well-known/openid-configuration' do |result|
      data = JSON.parse(result.stdout)
      expect(data['issuer']).to eq('http://localhost:8080/dex')
    end
  end

  it 'succesfully redirects /pun/sys/activejobs' do
    browser.goto "#{ctr_base_url}/pun/sys/activejobs"
    wait_for_page(url: "#{ctr_base_url}/pun/sys/dashboard/activejobs",
                  title: 'Dashboard - Open OnDemand', table_id: 'job_status_table')
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard/activejobs")
    expect(browser.title).to eq('Dashboard - Open OnDemand')
    expect(browser.table(id: 'job_status_table').present?).to be true
  end

  it 'redirects from /pun/sys/activejobs and preserves query params' do
    browser.goto "#{ctr_base_url}/pun/sys/activejobs?jobcluster=all&jobfilter=all"
    wait_for_page(url: "#{ctr_base_url}/pun/sys/dashboard/activejobs?jobcluster=all&jobfilter=all",
                  title: 'Dashboard - Open OnDemand', table_id: 'job_status_table')
    browser.screenshot.save 'activejobs.png'
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard/activejobs?jobcluster=all&jobfilter=all")
    expect(browser.title).to eq('Dashboard - Open OnDemand')
    expect(browser.table(id: 'job_status_table').present?).to be true
  end

  it 'redirects /pun/sys/file-editor#index' do
    browser.goto "#{ctr_base_url}/pun/sys/file-editor"
    wait_for_page(url: "#{ctr_base_url}/pun/sys/dashboard/files/fs/home/ood",
                  title: /File browsing - Open OnDemand\b/, table_id: 'directory-contents')
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard/files/fs/home/ood")
    expect(browser.title).to match(/File browsing - Open OnDemand\b/)
    expect(browser.table(id: 'directory-contents').present?).to be true
  end

  it 'redirects /pun/sys/file-editor and preserves the file' do
    browser.goto "#{ctr_base_url}/pun/sys/file-editor/edit/home/ood/.bashrc"
    wait_for_page(url:   "#{ctr_base_url}/pun/sys/dashboard/files/edit/fs/home/ood/.bashrc",
                  title: 'File Editor - Open OnDemand - .bashrc')
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard/files/edit/fs/home/ood/.bashrc")
    expect(browser.title).to eq('File Editor - Open OnDemand - .bashrc')
  end

  it 'redirects /pun/sys/files#index' do
    browser.goto "#{ctr_base_url}/pun/sys/files"
    wait_for_page(url: "#{ctr_base_url}/pun/sys/dashboard/files/fs/home/ood",
                  title: /File browsing - Open OnDemand\b/, table_id: 'directory-contents')
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard/files/fs/home/ood")
    expect(browser.title).to match(/File browsing - Open OnDemand\b/)
    expect(browser.table(id: 'directory-contents').present?).to be true
  end

  it 'redirects /pun/sys/files and preserves the path' do
    browser.goto "#{ctr_base_url}/pun/sys/files/fs/var/www/ood"
    wait_for_page(url: "#{ctr_base_url}/pun/sys/dashboard/files/fs/var/www/ood",
                  title: /File browsing - Open OnDemand\b/, table_id: 'directory-contents')
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard/files/fs/var/www/ood")
    expect(browser.title).to match(/File browsing - Open OnDemand\b/)
    expect(browser.table(id: 'directory-contents').present?).to be true
  end
end
