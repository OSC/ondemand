require 'beaker-rspec'
require 'package/package_helper'
require 'support/e2e_examples'

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
  c.before(:suite) do
    bootstrap_repos
    ondemand_repo
    install_ondemand
    upload_portal_config('portal.yml')
    update_ood_portal
    restart_apache
    restart_dex
    bootstrap_user
    # Need by node/rnode proxy tests
    bootstrap_flask
  end
end
