# frozen_string_literal: true

require 'spec_helper_e2e'

describe 'Nginx stage' do
  def browser
    @browser ||= new_browser
  end

  after do
    if @browser
      begin
        @browser.close
      ensure
        clean_nginx
      end
    end
  end

  context 'missing users' do
    # These paths belong to the Beaker target, not the machine running RSpec.
    def assert_disabled_user_files_absent
      on hosts, <<~'SH'
        set -e
        for path in /var/run/ondemand-nginx/deleted_user \
                    /var/lib/ondemand-nginx/config/puns/deleted_user.conf \
                    /var/lib/ondemand-nginx/config/puns/deleted_user.secret_key_base.txt \
                    /var/lib/ondemand-nginx/config/puns/deleted_user.conf.cleanup_pending; do
          if [ -e "$path" ] || [ -L "$path" ]; then
            echo "Disabled-user cleanup left $path" >&2
            exit 1
          fi
        done
      SH
    end

    before(:all) do
      on hosts, 'mkdir /var/run/ondemand-nginx/deleted_user'
      on hosts, 'chmod 600 /var/run/ondemand-nginx/deleted_user'
      on hosts, 'echo -n 11111111 > /var/run/ondemand-nginx/deleted_user/passenger.pid'
      on hosts, 'echo -n 11111111 > /var/lib/ondemand-nginx/config/puns/deleted_user.conf'
      on hosts, 'echo -n 11111111 > /var/lib/ondemand-nginx/config/puns/deleted_user.secret_key_base.txt'
    end

    after(:all) do
      on hosts, 'rm -rf /var/run/ondemand-nginx/deleted_user'
      on hosts, 'rm -f /var/lib/ondemand-nginx/config/puns/deleted_user.conf /var/lib/ondemand-nginx/config/puns/deleted_user.secret_key_base.txt'
      on hosts, 'rm -f /var/lib/ondemand-nginx/config/puns/deleted_user.conf.cleanup_pending'
    end

    it 'cleans disabled-user files on the target and can repeat cleanup' do
      # get the 'ood' users' pun ready
      browser_login(browser)
      expect(browser.title).to eq('Dashboard - Open OnDemand')

      # Note there's no error here about 'deleted_user'
      on hosts, '/opt/ood/nginx_stage/sbin/nginx_stage nginx_clean --force' do |result|
        assert_equal result.stdout, "ood\ndeleted_user (disabled)\n"
        expect(result.stderr).to eq('')
      end
      assert_disabled_user_files_absent

      on hosts, '/opt/ood/nginx_stage/sbin/nginx_stage nginx_clean --force' do |result|
        expect(result.stdout).not_to include('deleted_user')
        expect(result.stderr).to eq('')
      end
      assert_disabled_user_files_absent
    end
  end
end
