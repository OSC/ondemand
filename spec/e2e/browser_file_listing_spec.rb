# frozen_string_literal: true

require 'securerandom'
require 'spec_helper_e2e'

RSpec.describe 'OnDemand directory listings', type: :system do
  attr_accessor :browser

  let(:fixture_path) { "/home/ood/e2e-file-listing-#{SecureRandom.hex(8)}" }
  let(:fixture_names) { ['empty', 'listing-fixture.txt', 'vanishing'] }

  def listing_url(path)
    "#{ctr_base_url}/pun/sys/dashboard/files/fs#{path}"
  end

  def listing_names
    browser.elements(css: '#directory-contents tbody .name').map(&:text).sort
  end

  def visible_error_alerts
    browser.divs(class: 'alert-danger').select(&:present?)
  end

  def listing_loaded?(path, names)
    browser.url == listing_url(path) &&
      browser.table(id: 'directory-contents').present? &&
      !browser.div(id: 'tloading_spinner').present? &&
      visible_error_alerts.empty? &&
      listing_names == names
  end

  def wait_for_listing(path, names)
    Watir::Wait.until(timeout: 30, interval: 0.25,
                      message: "Expected directory #{path} with entries #{names.inspect} and no listing error") do
      listing_loaded?(path, names)
    end
  end

  def open_directory(name)
    Watir::Wait.until(timeout: 30, interval: 0.25, message: "Could not click directory #{name}") do
      link = browser.link(class: 'name', text: name)
      link.scroll.to(:center)
      link.click
      true
    rescue Selenium::WebDriver::Error::ElementClickInterceptedError
      false
    end
  end

  before do
    on hosts, <<~SH
      set -e
      install -d -m 755 #{fixture_path}/empty #{fixture_path}/vanishing
      install -m 644 /dev/null #{fixture_path}/listing-fixture.txt
      chown -R ood:ood #{fixture_path}
    SH
    self.browser = new_browser
    browser_login(browser)
    browser.goto listing_url(fixture_path)
    wait_for_listing(fixture_path, fixture_names)
  end

  after do
    browser&.close
  ensure
    on hosts, "rm -rf -- #{fixture_path}"
  end

  it 'loads the expected directory entries from the packaged app' do
    expect(listing_names).to eq(fixture_names)
    expect(visible_error_alerts).to be_empty
  end

  it 'loads an empty directory without accepting stale rows or a placeholder as a file' do
    open_directory('empty')
    wait_for_listing("#{fixture_path}/empty", [])

    expect(browser.element(css: '#directory-contents tbody td.dt-empty')).to be_present
    expect(listing_names).to be_empty
    expect(visible_error_alerts).to be_empty
  end

  it 'reports a failed directory request without claiming successful navigation' do
    # Leave a stale link in the loaded table so the next click makes a real failed JSON request.
    on hosts, "rmdir -- #{fixture_path}/vanishing"
    open_directory('vanishing')

    Watir::Wait.until(timeout: 30, interval: 0.25, message: 'Expected a directory listing error') do
      visible_error_alerts.any? &&
        !browser.div(id: 'tloading_spinner').present?
    end

    expect(visible_error_alerts.map(&:text).join("\n")).not_to be_empty
    expect(browser.url).to eq(listing_url(fixture_path))
    expect(browser.div(id: 'tloading_spinner')).not_to be_present
  end
end
