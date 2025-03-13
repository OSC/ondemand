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
    sleep 3
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

  it 'correctly passes query parameters to node URIs' do
    url = "#{ctr_base_url}/node/localhost/5001/one/with-query-params?artist=the%20beatles&album=let%20it%20be"
    browser.goto(url)
    expect(browser.url).to eq(url)
    expect(browser.div(id: 'test-div').present?).to be true
  end

  it 'correctly passes query parameters to rnode URIs' do
    url = "#{ctr_base_url}/rnode/localhost/5000/one/with-query-params?artist=the%20beatles&album=let%20it%20be"
    browser.goto(url)
    expect(browser.url).to eq(url)
    expect(browser.div(id: 'test-div').present?).to be true
  end

  it '/nginx/init needs a redirect' do
    url = "#{ctr_base_url}/nginx/init"
    browser.goto url
    expect(browser.text).to eq('Error -- requires a `redir` query parameter')
    expect(browser.url).to eq(url)
  end 

  it '/nginx/init correctly redirects to /pun/sys/dashboard' do
    browser.goto "#{ctr_base_url}/nginx/init?redir=/pun/sys/dashboard"
    # TODO somehow ensure it's a 302 response on redirect
    # no status response codes available so urls or page elements need used somehow
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard")
  end

  it '/nginx/init will not redirect to another host' do
    url = "#{ctr_base_url}/nginx/init?redir=github.com"
    browser.goto "#{ctr_base_url}/nginx/init?redir=github.com"
    expect(browser.text).to eq('Error -- bad `redir` request (github.com)')
    expect(browser.url).to eq(url)
  end

  it '/nginx/init will not redirect to another url with a scheme' do
    url = "#{ctr_base_url}/nginx/init?redir=https://github.com"
    browser.goto url
    expect(browser.text).to eq('Error -- bad `redir` request (https://github.com)')
    expect(browser.url).to eq(url)
  end

  it '/nginx/init will not redirect to /node' do
    url = "#{ctr_base_url}/nginx/init?redir=/node/localhost/5001"
    browser.goto url
    expect(browser.text).to eq('Error -- bad `redir` request (/node/localhost/5001)')
    expect(browser.url).to eq(url)
  end

  # TODO: returns error message when it can't correctly boot the PUN
  # it 'returns 404 and error when PUN not booted on init' do
  #   browser.goto "#{ctr_base_url}/nginx/init"
  # end

  # TODO: examine "stop" else logic as it is skipping to "or http.http200(r)" choice each run
  it '/nginx/stop does not needs a redirect' do
    url = "#{ctr_base_url}/nginx/stop"
    browser.goto url
    expect(browser.text).to eq('Success')
    expect(browser.url).to eq(url)
  end

  it '/nginx/stop wont redirect to another host' do
    url = "#{ctr_base_url}/nginx/stop?redir=github.com"
    browser.goto url
    expect(browser.text).to eq('Error -- bad `redir` request (github.com)')
    expect(browser.url).to eq(url)
  end

  it '/nginx/stop wont redirect to a url with a scheme' do
    url = "#{ctr_base_url}/nginx/stop?redir=https://github.com"
    browser.goto url
    expect(browser.text).to eq('Error -- bad `redir` request (https://github.com)')
    expect(browser.url).to eq(url)
  end

  it '/nginx/stop wont redirect to /node' do
    url = "#{ctr_base_url}/nginx/stop?redir=/node/localhost/5001"
    browser.goto url
    expect(browser.text).to eq('Error -- bad `redir` request (/node/localhost/5001)')
    expect(browser.url).to eq(url)
  end

  it '/nginx/stop will redirect to /pun/*' do
    browser.goto "#{ctr_base_url}/nginx/stop?redir=/pun/sys/dashboard"
    expect(browser.url).to eq("#{ctr_base_url}/pun/sys/dashboard")
  end

  # TODO: stub PUN that does not boot
  # it 'returns "bad redir error" when PUN not booted' do
  #  browser.goto "#{ctr_base_url}/nginx/init?redir=/nothing"
  # end

  # TODO: check content of page.
end