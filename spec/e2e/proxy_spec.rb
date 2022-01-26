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

  it 'node correctly returns redir error when no redirect is given on init' do
    browser.goto "#{ctr_base_url}/nginx/init"
    expect(browser.text).to eq('Error -- requires a `redir` query parameter')
  end 

  it 'redirects to /pun/sys/dashboard when redirect is given on init' do
    browser.goto "#{ctr_base_url}/nginx/init?redir=/pun/sys/dashboard"
    # TODO ensure it's a 302 response on redirect
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard")
  end

  it 'node correctly returns "bad redir error" when redirect to "github.com" given on init' do
    browser.goto "#{ctr_base_url}/nginx/init?redir=github.com"
    expect(browser.text).to eq('Error -- bad `redir` request (github.com)')
  end

  it 'node correctly returns "bad redir error" when redirect to "https://github.com" given on init' do
    browser.goto "#{ctr_base_url}/nginx/init?redir=https://github.com"
    expect(browser.text).to eq('Error -- bad `redir` request (https://github.com)')
  end

  it 'node correctly returns "bad redir error" when redirect to "/node/localhost/5001" is given on init' do
    browser.goto "#{ctr_base_url}/nginx/init?redir=/node/localhost/5001"
    expect(browser.text).to eq('Error -- bad `redir` request (/node/localhost/5001)')
  end

  # TODO returns 404 and error message when it can't correctly boot the PUN
  # it 'returns 404 and error when PUN not booted on init' do
  #   browser.goto "#{ctr_base_url}/nginx/init"
  # end

  # currently returns Success
  # it 'node correctly returns "bad redir error" when no redirect is given on stop' do
  #   browser.goto "#{ctr_base_url}/nginx/stop"
  #   expect(browser.selector(name: 'pre')).to eq('Error -- bad `redir` request ()')
  # end

  # TODO returns correct error page on stop when no redirect given
  # it 'returns correct error page when no redirect is given on stop' do
    # browser.goto "#{ctr_base_url}/nginx/stop"
    # expect(browser.url).to eq(#route to whatever error page)
    # expect(resonse.status).to have_http_status(200)
  # end

  it 'node correctly returns "bad redir error" when redirect to "github.com" given on stop' do
    browser.goto "#{ctr_base_url}/nginx/stop?redir=github.com"
    expect(browser.text).to eq('Error -- bad `redir` request (github.com)')
  end

  it 'node correctly returns "bad redir error" when redirect to "https://github.com" given on stop' do
    browser.goto "#{ctr_base_url}/nginx/stop?redir=https://github.com"
    expect(browser.text).to eq('Error -- bad `redir` request (https://github.com)')
  end

  it 'node correctly returns "bad redir error" when redirect to "/node/localhost/5001" is given on stop' do
    browser.goto "#{ctr_base_url}/nginx/stop?redir=/node/localhost/5001"
    expect(browser.text).to eq('Error -- bad `redir` request (/node/localhost/5001)')
  end

  # TODO returns correct error page on stop when a redirect is given
  # it 'returns 404 and error when PUN not booted' do
  #  browser.goto "#{ctr_base_url}/nginx/init?redir=/nothing"
  # end

  it 'node correctly returns 200 when no redirect is given on noop' do
    browser.goto "#{ctr_base_url}/nginx/noop"
    expect(browser.text).to eq('Success')
  end 

  it 'node correctly redirects to /pun/sys/dashboard with 307 when no redirect is given on noop' do
    # Currently returns Success
    browser.goto "#{ctr_base_url}/nginx/noop"
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard")
  end 

  it 'node correctly returns "bad redir error" when redirect to "github.com" given on noop' do
    browser.goto "#{ctr_base_url}/nginx/noop?redir=github.com"
    expect(browser.text).to eq('Error -- bad `redir` request (github.com)')
  end

  it 'node correctly returns "bad redir error" when redirect to "https://github.com" given on noop' do
    browser.goto "#{ctr_base_url}/nginx/noop?redir=https://github.com"
    expect(browser.text).to eq('Error -- bad `redir` request (https://github.com)')
  end

  it 'node correctly returns "bad redir error" when redirect to "/node/localhost/5001" is given on noop' do
    browser.goto "#{ctr_base_url}/nginx/noop?redir=/node/localhost/5001"
    expect(browser.text).to eq('Error -- bad `redir` request ()')
  end

  # TODO: check content of page.
end