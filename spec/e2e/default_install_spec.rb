require 'spec_helper_e2e'

describe 'Default install' do
  def browser
    @browser ||= new_browser
  end

  before(:all) do
    upload_portal_config('empty.yml')
    update_ood_portal
    restart_apache
  end

  describe file(host_portal_config) do
    it { is_expected.to be_file }
    expected = File.join(proj_root, 'ood-portal-generator/spec/fixtures/ood-portal.conf.default')
    its(:content) { is_expected.to eq(File.read(expected)) }
  end

  describe 'default webpage' do
    def expect_page(page)
      browser.goto "http://localhost:8081#{page}"
      auth_docs = 'https://osc.github.io/ood-documentation/latest/authentication.html'

      expect(browser.url).to eq("http://localhost:8081/public/need_auth.html")
      expect(browser.h1(text: 'Welcome to Open OnDemand!').present?).to be true
      expect(browser.a(text: 'the authentication documentation', href: auth_docs).present?).to be true
      expect(browser.a(text: 'Go to Documentation.', href: auth_docs).present?).to be true
    end

    it 'is the only page' do
      expect_page('/')
      expect_page('/anywhere')
      expect_page('/public/maintenance/index.html')
      expect_page('/pun/sys/dashboard')
      expect_page('/nginx/init')
    end
  end

end
