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
    browser.execute_script(<<~JS)
      const entries = Array.from(document.querySelectorAll('#directory-contents tbody .name'));
      return entries.filter(element => element.getClientRects().length > 0 &&
        getComputedStyle(element).visibility !== 'hidden').map(element => element.innerText).sort();
    JS
  end

  def visible_error_alerts
    browser.divs(class: 'alert-danger').select(&:present?)
  end

  def listing_state
    {
      url:           browser.url,
      names:         listing_names,
      table_visible: browser.table(id: 'directory-contents').present?,
      loading:       browser.div(id: 'tloading_spinner').present?,
      errors:        visible_error_alerts.map(&:text)
    }
  end

  def wait_for_listing(path, names)
    state = nil
    message = proc { "Expected directory #{path} with entries #{names.inspect}; last observed #{state.inspect}" }
    Watir::Wait.until(timeout: 30, interval: 0.25, message: message) do
      state = listing_state
      state[:url] == listing_url(path) && state[:table_visible] &&
        !state[:loading] && state[:errors].empty? && state[:names] == names
    end
  end

  def open_directory(name)
    # Exercise the directory link without depending on headless pointer positioning.
    browser.table(id: 'directory-contents').link(class: 'name', text: name).send_keys(:enter)
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

    state = nil
    message = proc { "Expected a directory listing error; last observed #{state.inspect}" }
    Watir::Wait.until(timeout: 30, interval: 0.25, message: message) do
      state = listing_state
      state[:errors].any? && !state[:loading]
    end

    expect(visible_error_alerts.map(&:text).join("\n")).not_to be_empty
    expect(browser.url).to eq(listing_url(fixture_path))
    expect(browser.div(id: 'tloading_spinner')).not_to be_present
  end
end
