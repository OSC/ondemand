require 'watir'

describe 'OnDemand browser test' do
  let(:browser) { Watir::Browser.new :chrome, headless: true, options: {args: ['--disable-dev-shm-usage']} }
  after(:each) { browser.close }

  it 'successfully logs into OnDemand' do
    browser.goto "http://localhost:8080"
    browser.text_field(id: 'username').set "ood@localhost"
    browser.text_field(id: 'password').set "password"
    browser.button(id: 'submit-login').click

    expect(browser.title).to eq('Dashboard - Open OnDemand')
  end
end
