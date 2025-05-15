# frozen_string_literal: true

# TODO: Refactor batch_connect_test.rb to include tests that require slurm
# (testing that things submit) and pull out/write tests for widgets (do not
# require form submission) into this file - perhaps a batch_connect_test/
# directory

require 'application_system_test_case'
require 'ood_core/job/adapters/slurm'

class BatchConnectWidgetsTest < ApplicationSystemTestCase
  def setup
    stub_sys_apps
    stub_user
    Configuration.stubs(:bc_dynamic_js).returns(true)
    Configuration.stubs(:bc_dynamic_js?).returns(true) #stub the alias too
  end

  def make_bc_app(dir, form)
    SysRouter.stubs(:base_path).returns(Pathname.new(dir))
    app_dir = "#{dir}/app".tap { |d| Dir.mkdir(d) }
    stub_scontrol
    stub_sacctmgr
    stub_git(app_dir)
    Pathname.new(app_dir).join('form.yml').write(form)
  end

  test 'path_selector can be hidden with data-hide-*' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - path
          - hide_path
        attributes:
          path:
            widget: 'path_selector'
            directory: "#{Rails.root}"
          hide_path:
            widget: 'select'
            options:
              - ['show path', 'show path']
              - ['hide path', 'hide path', data-hide-path: true]
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      base_id = 'batch_connect_session_context_path'

      visit new_batch_connect_session_context_url('sys/app')

      select('show path', from: 'batch_connect_session_context_hide_path')
      assert find('#batch_connect_session_context_path')
      assert find("[data-target='#batch_connect_session_context_path_path_selector']")

      select('hide path', from: 'batch_connect_session_context_hide_path')
      refute find('#batch_connect_session_context_path', visible: :hidden).visible?
      refute find("[data-target='#batch_connect_session_context_path_path_selector']", visible: :hidden).visible?
    end
  end
end