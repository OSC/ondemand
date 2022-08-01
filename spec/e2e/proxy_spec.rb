require 'spec_helper_e2e'

describe 'Node and Rnode proxies' do

  def browser
    @browser ||= new_browser
  end

  before(:all) do
    on hosts, 'mkdir -p /opt/extras'
    copy_files_to_dir("#{extra_fixtures}/*", '/opt/extras')
    upload_portal_config('portal_with_proxies.yml')
    update_ood_portal
    restart_apache
    restart_dex

    on hosts, '/opt/extras/simple_origin_server.py >/tmp/rnode.out 2>&1 &'
    on hosts,
       'FLASK_PORT=5001 FLASK_BASE_URL=/node/localhost/5001 /opt/extras/simple_origin_server.py >/tmp/node.out 2>&1 &'

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