require 'watir'
require_relative 'e2e_helper'

describe 'Pun Pre Hook' do

  def browser
    @browser ||= new_browser
  end

  after(:all) do
    Rake::Task['test:stop_test_container'].execute
    browser.close
  end

  it 'does not crash login when pre hook crashes' do
    mnts = ["-v", "#{hook_fixture('bad_pre_hook')}:/opt/hooks/pun_pre_hook"]
    mnts.concat ["-v", "#{portal_fixture('portal_with_prehook.yml')}:/etc/ood/config/ood_portal.yml"]
    Rake::Task['test:start_test_container'].execute(mount_args: mnts)

    browser_login(browser)
    browser.goto ctr_base_url
    expect(browser.title).to eq('Dashboard - Open OnDemand')

    hook_out = container_exec("cat /tmp/hook.out")
    expect(hook_out.chomp).to eq('/opt/hooks/pun_pre_hook: line 4: wont_find_cmd: command not found')
  end

  it 'does not crash login when pre hook is misconfigured' do
    # no mount point for hook file
    mnts = ["-v", "#{portal_fixture('portal_with_prehook.yml')}:/etc/ood/config/ood_portal.yml"]
    Rake::Task['test:start_test_container'].execute(mount_args: mnts)

    browser_login(browser)
    browser.goto ctr_base_url
    expect(browser.title).to eq('Dashboard - Open OnDemand')
  end

  it 'sets environment variables in the pre hook' do
    mnts = ["-v", "#{hook_fixture('good_pre_hook')}:/opt/hooks/pun_pre_hook"]
    mnts.concat ["-v", "#{portal_fixture('portal_with_prehook.yml')}:/etc/ood/config/ood_portal.yml"]
    Rake::Task['test:start_test_container'].execute(mount_args: mnts)

    browser_login(browser)
    browser.goto ctr_base_url
    expect(browser.title).to eq('Dashboard - Open OnDemand')
    hook_out = container_exec("cat /tmp/hook.out")
    expect(hook_out).to eq("input args are --user ood\naccess token set\nemail claim set\n")
  end
end