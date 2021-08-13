require_relative '../support/e2e_examples'
require_relative 'e2e_helper'

describe 'Node and Rnode proxies' do
  before(:all) do
    mnts = ["-v", "#{extra_fixtures}:/opt/extras"]
    mnts.concat ["-v", "#{portal_fixture('portal_with_proxies.yml')}:/etc/ood/config/ood_portal.yml"]
    Rake::Task['test:start_test_container'].execute(mount_args: mnts)

    container_exec("/bin/bash -c '/opt/extras/simple_origin_server.py >/tmp/rnode.out 2>&1 &'")
    container_exec("/bin/bash -c 'FLASK_PORT=5001 FLASK_BASE_URL=/node/localhost/5001 /opt/extras/simple_origin_server.py >/tmp/node.out 2>&1 &'")
  end

  after(:all) do
    Rake::Task['test:stop_test_container'].execute
  end

  include_examples 'node-rnode-proxies'
end