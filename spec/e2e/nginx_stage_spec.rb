# frozen_string_literal: true

require 'spec_helper_e2e'

describe 'Nginx stage' do
  def browser
    @browser ||= new_browser
  end

  after(:each) do
    browser.close
    on hosts, '/opt/ood/nginx_stage/sbin/nginx_stage nginx_clean --force'
  end

  context 'missing users' do
    before(:all) do
      on hosts, 'mkdir /var/run/ondemand-nginx/deleted_user'
      on hosts, 'chmod 600 /var/run/ondemand-nginx/deleted_user'
      on hosts, 'echo -n 74 > /var/run/ondemand-nginx/deleted_user/passenger.pid'
    end

    after(:all) do
      on hosts, 'rm -rf /var/run/ondemand-nginx/deleted_user'
    end

    it 'does not crash login when pre hook is misconfigured' do
      # get the 'ood' users' pun ready
      browser_login(browser)
      browser.goto ctr_base_url
      expect(browser.title).to eq('Dashboard - Open OnDemand')

      # Note there's no error here about 'deleted_user'
      expect { `/opt/ood/nginx_stage/sbin/nginx_stage nginx_clean --force` }.to output('ood\n')
    end
  end
end
