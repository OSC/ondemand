# frozen_string_literal: true

require 'watir'
require_relative '../e2e/e2e_helper'

shared_examples_for 'browser-tests' do
  def browser
    @browser ||= new_browser
  end

  before(:all) do
    browser_login(browser)
  end

  after(:all) do
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

shared_examples_for 'node-rnode-proxies' do
  def browser
    @browser ||= new_browser
  end

  before(:all) do
    browser_login(browser)
  end

  after(:all) do
    browser.close
  end

  it 'rnode proxies directly to the origin' do
    browser.goto "#{ctr_base_url}/rnode/localhost/5000/simple-page"
    expect(browser.url).to eq("#{ctr_base_url}/rnode/localhost/5000/simple-page")
    expect(browser.div(id: 'test-div').present?).to be true
  end

  it 'rnode redirects to the origin' do
    browser.goto "#{ctr_base_url}/rnode/localhost/5000/simple-redirect"
    expect(browser.url).to eq("#{ctr_base_url}/rnode/localhost/5000/simple-page")
    expect(browser.div(id: 'test-div').present?).to be true
  end

  it 'rnode redirects to the origin when no path is given' do
    browser.goto "#{ctr_base_url}/rnode/localhost/5000"
    expect(browser.url).to eq("#{ctr_base_url}/rnode/localhost/5000/simple-page")
    expect(browser.div(id: 'test-div').present?).to be true
  end

  it 'rnode redirects to the origin when only root is given' do
    browser.goto "#{ctr_base_url}/rnode/localhost/5000/"
    expect(browser.url).to eq("#{ctr_base_url}/rnode/localhost/5000/simple-page")
    expect(browser.div(id: 'test-div').present?).to be true
  end

  it 'rnode correctly redirects relative urls' do
    browser.goto "#{ctr_base_url}/rnode/localhost/5000/one/two/three/relative-redirect"
    expect(browser.url).to eq("#{ctr_base_url}/rnode/localhost/5000/one/one-level-down")
    expect(browser.div(id: 'test-div').present?).to be true

    browser.goto "#{ctr_base_url}/rnode/localhost/5000/one/two/relative-redirect"
    expect(browser.url).to eq("#{ctr_base_url}/rnode/localhost/5000/simple-page")
    expect(browser.div(id: 'test-div').present?).to be true

    browser.goto "#{ctr_base_url}/rnode/localhost/5000/one/relative-redirect"
    expect(browser.url).to eq("#{ctr_base_url}/rnode/localhost/5000/one/one-level-down")
    expect(browser.div(id: 'test-div').present?).to be true
  end

  it 'node proxies directly to the origin' do
    browser.goto "#{ctr_base_url}/node/localhost/5001/simple-page"
    expect(browser.url).to eq("#{ctr_base_url}/node/localhost/5001/simple-page")
    expect(browser.div(id: 'test-div').present?).to be true
  end

  it 'node redirects to the origin' do
    browser.goto "#{ctr_base_url}/node/localhost/5001/simple-redirect"
    expect(browser.url).to eq("#{ctr_base_url}/node/localhost/5001/simple-page")
    expect(browser.div(id: 'test-div').present?).to be true
  end

  it 'node redirects to the origin with nothing extra in the path' do
    browser.goto "#{ctr_base_url}/node/localhost/5001"
    expect(browser.url).to eq("#{ctr_base_url}/node/localhost/5001/simple-page")
    expect(browser.div(id: 'test-div').present?).to be true
  end

  it 'node redirects to the origin when only root is given' do
    browser.goto "#{ctr_base_url}/node/localhost/5001/"
    expect(browser.url).to eq("#{ctr_base_url}/node/localhost/5001/simple-page")
    expect(browser.div(id: 'test-div').present?).to be true
  end

  it 'node correctly redirects relative urls' do
    browser.goto "#{ctr_base_url}/node/localhost/5001/one/two/three/relative-redirect"
    expect(browser.url).to eq("#{ctr_base_url}/node/localhost/5001/one/one-level-down")
    expect(browser.div(id: 'test-div').present?).to be true

    browser.goto "#{ctr_base_url}/node/localhost/5001/one/two/relative-redirect"
    expect(browser.url).to eq("#{ctr_base_url}/node/localhost/5001/simple-page")
    expect(browser.div(id: 'test-div').present?).to be true

    browser.goto "#{ctr_base_url}/node/localhost/5001/one/relative-redirect"
    expect(browser.url).to eq("#{ctr_base_url}/node/localhost/5001/one/one-level-down")
    expect(browser.div(id: 'test-div').present?).to be true
  end
end
