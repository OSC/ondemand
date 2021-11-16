# frozen_string_literal: true

require 'spec_helper_e2e'

describe 'OnDemand browser test' do # rubocop:disable RSpec/DescribeClass
  def browser
    @browser ||= new_browser
  end

  before do
    browser_login(browser)
  end

  after do
    browser.close
  end

  it 'successfully loads dashboard no path' do
    browser.goto ctr_base_url
    expect(browser.title).to eq('Dashboard - Open OnDemand')
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
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard/files/edit/home/ood/.bashrc")
    expect(browser.title).to eq('File Editor - Open OnDemand - .bashrc')
  end

  it 'redirects /pun/sys/files#index' do
    browser.goto "#{ctr_base_url}/pun/sys/files"
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard/files/fs/home/ood")
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
