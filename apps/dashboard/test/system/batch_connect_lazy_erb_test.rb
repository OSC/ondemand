# frozen_string_literal: true

require 'application_system_test_case'

class BatchConnectLazyErbTest < ApplicationSystemTestCase
  def setup
    stub_user
    stub_clusters
    Rails.cache.clear
  end

  def teardown
    Rails.cache.clear
  end

  def write_bc_app(app_dir, side_effect:, title:)
    FileUtils.mkdir_p(app_dir)
    File.write(File.join(app_dir, 'manifest.yml'), <<~YAML)
      ---
      name: Lazy ERB Test
      category: Interactive Apps
      role: batch_connect
    YAML
    File.write(File.join(app_dir, 'form.yml.erb'), <<~ERB)
      ---
      title: "#{title}"
      cluster: "oakley"
      form:
        - bc_account
      <%- File.write('#{side_effect}', 'evaluated') -%>
    ERB
  end

  test 'usr apps do not evaluate form ERB until the form is opened' do
    Dir.mktmpdir do |dir|
      side_effect = File.join(dir, 'erb_evaluated')
      gateway = File.join(dir, 'gateway')
      write_bc_app(File.join(gateway, 'lazy_app'), side_effect: side_effect, title: 'Usr Form Title')

      Configuration.stubs(:app_sharing_enabled?).returns(true)
      UsrRouter.stubs(:owners).returns(['shared'])
      UsrRouter.stubs(:base_path).with(:owner => 'shared').returns(Pathname.new(gateway))
      # Avoid recently used widget building session context on the dashboard.
      BatchConnect::Session.stubs(:cache_root).returns(Pathname.new(File.join(dir, 'empty_cache')).tap { |p| FileUtils.mkdir_p(p) })
      stub_user_configuration({ dashboard_layout: { rows: [] } })

      visit root_path
      refute File.exist?(side_effect), 'usr form ERB should not run on dashboard load'

      visit new_batch_connect_session_context_url('usr/shared/lazy_app')
      assert File.exist?(side_effect), 'usr form ERB should run when the form is opened'
      assert_selector 'h3', text: 'Usr Form Title'
    end
  end

  test 'sys apps still evaluate form ERB on dashboard load' do
    Dir.mktmpdir do |dir|
      side_effect = File.join(dir, 'erb_evaluated')
      write_bc_app(File.join(dir, 'lazy_sys_app'), side_effect: side_effect, title: 'Sys Form Title')

      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      BatchConnect::Session.stubs(:cache_root).returns(Pathname.new(File.join(dir, 'empty_cache')).tap { |p| FileUtils.mkdir_p(p) })
      stub_user_configuration({ dashboard_layout: { rows: [] } })

      visit root_path
      assert File.exist?(side_effect), 'sys form ERB should still run on dashboard load'

      visit new_batch_connect_session_context_url('sys/lazy_sys_app')
      assert_selector 'h3', text: 'Sys Form Title'
    end
  end

  test 'recently used apps still build session context for usr apps' do
    Dir.mktmpdir do |dir|
      side_effect = File.join(dir, 'erb_evaluated')
      gateway = File.join(dir, 'gateway')
      write_bc_app(File.join(gateway, 'lazy_app'), side_effect: side_effect, title: 'Recent Usr Title')

      cache_root = File.join(dir, 'cache')
      FileUtils.mkdir_p(cache_root)
      File.write(File.join(cache_root, 'usr_shared_lazy_app.json'), '{"bc_account":"test"}')

      Configuration.stubs(:app_sharing_enabled?).returns(true)
      UsrRouter.stubs(:owners).returns(['shared'])
      UsrRouter.stubs(:base_path).with(:owner => 'shared').returns(Pathname.new(gateway))
      SysRouter.stubs(:base_path).returns(Pathname.new(File.join(dir, 'empty_sys')).tap { |p| FileUtils.mkdir_p(p) })
      BatchConnect::Session.stubs(:cache_root).returns(Pathname.new(cache_root))
      stub_user_configuration(
        {
          dashboard_layout: {
            rows: [{ columns: [{ width: 12, widgets: ['recently_used_apps'] }] }]
          }
        }
      )

      visit root_path
      assert File.exist?(side_effect), 'recently used usr apps should build session context'
      assert_selector 'div.recently-used-apps-header'
      assert_selector 'p.app-title', text: 'Recent Usr Title'
    end
  end
end
