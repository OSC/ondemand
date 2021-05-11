require 'watir'
require_relative 'e2e_helper'

describe 'Node and Rnode proxies' do

  def browser
    @browser ||= new_browser
  end

  before(:all) do
    mnts = ["-v", "#{extra_fixtures}:/opt/extras"]
    mnts.concat ["-v", "#{portal_fixture('portal_with_proxies.yml')}:/etc/ood/config/ood_portal.yml"]
    Rake::Task['test:start_test_container'].execute(mount_args: mnts)

    container_exec("/bin/bash -c '/opt/extras/simple_origin_server.py >/tmp/rnode.out 2>&1 &'")
    container_exec("/bin/bash -c 'FLASK_PORT=5001 FLASK_BASE_URL=/node/localhost/5001 /opt/extras/simple_origin_server.py >/tmp/node.out 2>&1 &'")
    browser_login(browser)
  end

  after(:all) do
    Rake::Task['test:stop_test_container'].execute
    browser.close
  end

  it 'rnode proxies directly to the origin' do
    browser.goto "#{ctr_base_url}/rnode/localhost/5000/simple-page"
    expect(browser.url).to eq("#{ctr_base_url}/rnode/localhost/5000/simple-page")
    expect(browser.div(id: "test-div").present?).to be true
  end

  it 'rnode redirects to the origin' do
    browser.goto "#{ctr_base_url}/rnode/localhost/5000/simple-redirect"
    expect(browser.url).to eq("#{ctr_base_url}/rnode/localhost/5000/simple-page")
    expect(browser.div(id: "test-div").present?).to be true
  end

  it 'rnode redirects to the origin when no path is given' do
    browser.goto "#{ctr_base_url}/rnode/localhost/5000"
    expect(browser.url).to eq("#{ctr_base_url}/rnode/localhost/5000/simple-page")
    expect(browser.div(id: "test-div").present?).to be true
  end

  it 'rnode redirects to the origin when only root is given' do
    browser.goto "#{ctr_base_url}/rnode/localhost/5000/"
    expect(browser.url).to eq("#{ctr_base_url}/rnode/localhost/5000/simple-page")
    expect(browser.div(id: "test-div").present?).to be true
  end

  it 'node proxies directly to the origin' do
    browser.goto "#{ctr_base_url}/node/localhost/5001/simple-page"
    expect(browser.url).to eq("#{ctr_base_url}/node/localhost/5001/simple-page")
    expect(browser.div(id: "test-div").present?).to be true
  end

  it 'rnode redirects to the origin' do
    browser.goto "#{ctr_base_url}/node/localhost/5001/simple-redirect"
    expect(browser.url).to eq("#{ctr_base_url}/node/localhost/5001/simple-page")
    expect(browser.div(id: "test-div").present?).to be true
  end

  it 'node redirects to the origin with nothing extra in the path' do
    browser.goto "#{ctr_base_url}/node/localhost/5001"
    expect(browser.url).to eq("#{ctr_base_url}/node/localhost/5001/simple-page")
    expect(browser.div(id: "test-div").present?).to be true
  end

  it 'node redirects to the origin when only root is given' do
    browser.goto "#{ctr_base_url}/node/localhost/5001/"
    expect(browser.url).to eq("#{ctr_base_url}/node/localhost/5001/simple-page")
    expect(browser.div(id: "test-div").present?).to be true
  end
end