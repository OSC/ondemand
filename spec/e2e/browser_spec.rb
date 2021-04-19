require 'watir'
require_relative 'e2e_helper'

describe 'OnDemand browser test' do

  def browser
    @browser ||= Watir::Browser.new :chrome, headless: true, options: { args: ['--disable-dev-shm-usage'] }
  end

  before(:all) do
    # sometimes you need to retry to let the container start up, so retry to make the tests
    # a little less flaky
    [*1..3].each do |try|
      begin
        browser_login(browser)
        break
      rescue => e
        raise e if try == 3

        `sleep 1`
      end
    end
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

  it 'redirects from /pun/sys/activejobs preserve query params' do
    browser.goto "#{ctr_base_url}/pun/sys/activejobs?jobcluster=all&jobfilter=all"
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard/activejobs?jobcluster=all&jobfilter=all")
    expect(browser.title).to eq('Dashboard - Open OnDemand')
    expect(browser.table(id: 'job_status_table').present?).to be true
  end
end
