# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'
require 'climate_control'
require 'timecop'

ENV['RAILS_ENV'] ||= 'test'
ENV['OOD_LOCALES_ROOT'] = Rails.root.join('config/locales').to_s


module ActiveSupport
  class TestCase
    # Add more helper methods to be used by all tests here...

    UserDouble = Struct.new(:name, :groups)

    class BrokenAdapter < OodCore::Job::Adapter
      SUBMIT_ERR_MSG = 'this adapter cannot submit jobs'
      def submit(_)
        raise StandardError, SUBMIT_ERR_MSG
      end
    end

    def with_modified_env(options, &block)
      ClimateControl.modify(options, &block)
    end

    def exit_success
      OpenStruct.new(:success? => true, :exitstatus => 0)
    end

    def exit_failure(exit_status = 1)
      OpenStruct.new(:success? => false, :exitstatus => exit_status)
    end

    def stub_usr_router
      Configuration.stubs(:app_sharing_enabled?).returns(true)
      Configuration.stubs(:app_development_enabled?).returns(true)
      stub_user

      UsrRouter.stubs(:base_path).with(:owner => 'me').returns(Pathname.new('test/fixtures/usr/me'))
      UsrRouter.stubs(:base_path).with(:owner => 'shared').returns(Pathname.new('test/fixtures/usr/shared'))
      UsrRouter.stubs(:base_path).with(:owner => 'cant_see').returns(Pathname.new('test/fixtures/usr/cant_see'))
      UsrRouter.stubs(:owners).returns(['me', 'shared', 'cant_see'])
    end

    def stub_user
      OodSupport::Process.stubs(:user).returns(UserDouble.new('me', ['me']))
      OodSupport::User.stubs(:new).returns(UserDouble.new('me', ['me']))
      Etc.stubs(:getlogin).returns('me')
    end

    def stub_sys_apps
      stub_clusters
      SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys_with_gateway_apps'))
    end

    def stub_clusters
      Configuration.instance_variable_set('@job_clusters', nil)
      OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))
    end

    def setup_usr_fixtures
      FileUtils.chmod 0o000, 'test/fixtures/usr/cant_see/'
    end

    def teardown_usr_fixtures
      FileUtils.chmod 0o755, 'test/fixtures/usr/cant_see/'
    end

    def bc_ele_id(ele)
      "batch_connect_session_context_#{ele}"
    end

    def button_link?(text, link)
      find('.btn', text: text)
      has_link?(link)
    end

    def stub_user_configuration(user_configuration_overrides)
      ::Configuration.stubs(:config).returns(user_configuration_overrides)
      user_configuration = UserConfiguration.new
      ::Configuration.unstub(:config)

      UserConfiguration.stubs(:new).returns(user_configuration)
    end

    def stub_scontrol
      ['owens', 'oakley'].each do |cluster|
        Open3
          .stubs(:capture3)
          .with({}, 'scontrol', 'show', 'part', '-o', '-M', cluster.to_s, stdin_data: '')
          .returns([File.read("test/fixtures/cmd_output/scontrol_show_partitions_#{cluster}.txt"), '', exit_success])
      end
    end

    def stub_sacctmgr
      Open3.stubs(:capture3)
           .with({}, 'sacctmgr', '-nP', 'show', 'users', 'withassoc', 'format=account,cluster,partition,qos', 'where', 'user=me', stdin_data: '')
           .returns([File.read('test/fixtures/cmd_output/sacctmgr_show_accts.txt'), '', exit_success])
    end

    def stub_du(directory = nil)
      directory ||= anything
      Open3
        .stubs(:capture3)
        .with('timeout', "#{Configuration.project_size_timeout}s", 'du', '-s', '-b', directory)
        .returns(['2097152 /directory/path', '', exit_success])
    end

    def stub_sinfo
      ['oakley', 'owens'].each do |cluster|
        Open3
          .stubs(:capture3)
          .with({}, 'sinfo', '-ho', "\u001E%c\u001F%n\u001F%f", '-M', cluster, stdin_data: '')
          .returns([File.read("test/fixtures/cmd_output/sinfo_nodes_#{cluster}.txt"), '', exit_success])
      end
    end

    # helper to stub clusters to be [ascend] becuase adding new cluster.d
    # files may conflict with existing tests.
    def stub_ascend
      ascend = OodCore::Cluster.new({ id: 'ascend', job: { adapter: 'slurm' } })
      OodAppkit.stubs(:clusters).returns(OodCore::Clusters.new([ascend]))
    end

    def output_fixture(file)
      File.read("#{Rails.root}/test/fixtures/file_output/#{file}")
    end

    def sys_bc_app(app: 'bc_paraview')
      r = SysRouter.new(app)
      BatchConnect::App.new(router: r)
    end

    def stub_git(dir)
      Open3.stubs(:capture3)
        .with('git', 'describe', '--always', '--tags', chdir: dir)
        .returns(['1.2.3', '', exit_success])
    end
  end
end

require 'mocha/minitest'
