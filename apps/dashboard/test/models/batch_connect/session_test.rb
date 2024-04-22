# frozen_string_literal: true

require 'test_helper'

module BatchConnect
  class SessionTest < ActiveSupport::TestCase
    def bc_jupyter_app
      r = PathRouter.new('test/fixtures/sys_with_gateway_apps/bc_jupyter')
      BatchConnect::App.new(router: r)
    end

    def create_double_session
      # FIXME: we should store status in the job, and then fix info to return an info object with id and status
      Class.new(BatchConnect::Session) do
        def completed?
          job_id == 'COMPLETED'
        end
      end
    end

    test 'should return no sessions if dbroot is empty' do
      Dir.mktmpdir('dbroot') do |dir|
        dir = Pathname.new(dir)
        BatchConnect::Session.stubs(:db_root).returns(dir)

        assert_equal [], BatchConnect::Session.all
      end
    end

    test 'old? ' do
      Tempfile.open do |f|
        BatchConnect::Session.any_instance.stubs(:db_file).returns(f.path)
        BatchConnect::Session.any_instance.stubs(:id).returns(File.basename(f.path))
        session = BatchConnect::Session.new({})

        refute session.old?, 'A newly created session should not be identified as old'
        Timecop.freeze((BatchConnect::Session.old_in_days + 1).days.from_now) do
          assert session.old?,
                 "A session unmodified for #{BatchConnect::Session.old_in_days + 1} days should be identified as old"
        end
      end
    end

    test 'days_till_old' do
      assert_equal 0, BatchConnect::Session.new.days_till_old, 'should be 0 since no id is set'
      assert_equal 0, BatchConnect::Session.new(id: 'A').days_till_old, 'should be 0 since no db file exists'

      File.stubs(:stat).returns(OpenStruct.new(mtime: Time.now))
      assert_equal BatchConnect::Session.old_in_days, BatchConnect::Session.new(id: 'A').days_till_old

      File.stubs(:stat).returns(OpenStruct.new(mtime: 1.day.ago))
      assert_equal BatchConnect::Session.old_in_days - 1, BatchConnect::Session.new(id: 'A').days_till_old
    end

    test 'Session.all should fail if valid session fields are not present' do
      double_session = create_double_session

      Dir.mktmpdir('dbroot') do |dir|
        dir = Pathname.new(dir)
        double_session.stubs(:db_root).returns(dir)

        [
          { id: 'A', job_id: 'COMPLETED', created_at: 100, cluster_id: 'owens' },
          { id: 'B', job_id: 'COMPLETED', created_at: 100 }
        ].each { |v| File.write dir.join(v[:id]), v.to_json }

        sessions = double_session.all
        assert_equal ['A'], sessions.map(&:id), "'B' should not to be added since it's missing cluster_id."
      end
    end

    test 'Session.all should return recently completed sessions' do
      double_session = create_double_session

      Dir.mktmpdir('dbroot') do |dir|
        dir = Pathname.new(dir)
        double_session.stubs(:db_root).returns(dir)

        [
          { id: 'A', job_id: 'RUNNING', created_at: 500, cluster_id: 'owens' },
          { id: 'B', job_id: 'COMPLETED', created_at: 100, cluster_id: 'owens' }
        ].each { |v| File.write dir.join(v[:id]), v.to_json }

        sessions = double_session.all
        assert_equal ['A', 'B'], sessions.map(&:id)
      end
    end

    test "Session.all should omit 'old' sessions and delete old job records" do
      double_session = create_double_session

      Dir.mktmpdir('dbroot') do |dir|
        dir = Pathname.new(dir)
        double_session.stubs(:db_root).returns(dir)

        [
          { id: 'A', job_id: 'RUNNING',   created_at: 100, cluster_id: 'owens' },
          { id: 'OLD', job_id: 'COMPLETED', created_at: 100, cluster_id: 'owens' }
        ].each { |v| File.write dir.join(v[:id]), v.to_json }

        Timecop.freeze((BatchConnect::Session.old_in_days + 1).days.from_now) do
          assert_equal ['A', 'OLD'], dir.children.map(&:basename).map(&:to_s).sort
          sessions = double_session.all
          assert_equal ['A'], sessions.map(&:id)
          assert_equal ['A'], dir.children.map(&:basename).map(&:to_s).sort
        end
      end
    end

    test 'Session.all should return ids order by created_at date DESC (newer to older)' do
      double_session = create_double_session

      Dir.mktmpdir('dbroot') do |dir|
        dir = Pathname.new(dir)
        double_session.stubs(:db_root).returns(dir)

        [
          { id: 'A', job_id: 'RUNNING', created_at: 500, cluster_id: 'owens' },
          { id: 'B', job_id: 'RUNNING', created_at: 100, cluster_id: 'owens' },
          { id: 'C', job_id: 'RUNNING', created_at: 300, cluster_id: 'owens' },
          { id: 'D', job_id: 'RUNNING', created_at: 400, cluster_id: 'owens' }
        ].each { |v| File.write dir.join(v[:id]), v.to_json }

        sessions = double_session.all
        assert_equal ['A', 'D', 'C', 'B'], sessions.map(&:id)
      end
    end

    test 'Session.all should return completed jobs after running jobs' do
      double_session = create_double_session

      Dir.mktmpdir('dbroot') do |dir|
        dir = Pathname.new(dir)
        double_session.stubs(:db_root).returns(dir)

        [
          { id: 'A', job_id: 'COMPLETED', created_at: 500, cluster_id: 'owens' },
          { id: 'B', job_id: 'RUNNING', created_at: 100, cluster_id: 'owens' },
          { id: 'C', job_id: 'RUNNING', created_at: 300, cluster_id: 'owens' },
          { id: 'D', job_id: 'RUNNING', created_at: 400, cluster_id: 'owens' }
        ].each { |v| File.write dir.join(v[:id]), v.to_json }

        sessions = double_session.all
        assert_equal ['D', 'C', 'B', 'A'], sessions.map(&:id),
                     'even though A is newest, since completed, it should appear last'
      end
    end

    test 'Session.all should rename and ignore corrupt session files' do
      # FIXME: this is a test to confirm how it currently works - but how is wrong
      # Session.all is a "getter" method - **it should not change state as it does**

      double_session = create_double_session
      Dir.mktmpdir('dbroot') do |dir|
        dir = Pathname.new(dir)
        double_session.stubs(:db_root).returns(dir)

        [
          { id: 'A', job_id: 'RUNNING', created_at: 500, cluster_id: 'owens' }
        ].each { |v| File.write dir.join(v[:id]), v.to_json }

        File.write dir.join('bad1'), ''
        File.write dir.join('bad2'), '{)'

        assert_equal ['A', 'bad1', 'bad2'], dir.children.map(&:basename).map(&:to_s).sort
        sessions = double_session.all
        assert_equal ['A'], sessions.map(&:id)
        assert_equal ['A', 'bad1.bak', 'bad2.bak'], dir.children.map(&:basename).map(&:to_s).sort
      end
    end

    test 'should ignore *.bak files in dbroot even if valid' do
      Dir.mktmpdir('dbroot') do |dir|
        dir = Pathname.new(dir)
        BatchConnect::Session.stubs(:db_root).returns(dir)
        BatchConnect::Session.any_instance.stubs(:completed?).returns(false)

        [
          { id: 'A', job_id: 'COMPLETED', created_at: 500, cluster_id: 'owens' },
          { id: 'B', job_id: 'COMPLETED', created_at: 100, cluster_id: 'owens' },
          { id: 'C', job_id: 'COMPLETED', created_at: 300, cluster_id: 'owens' }
        ].each do |v|
          File.open(dir.join(v[:id]), 'w') do |f|
            f.write v.to_json
          end
        end
        File.open(dir.join('D.bak'), 'w') do |f|
          f.write({ id: 'D', created_at: 400 }.to_json)
        end

        assert_equal ['A', 'B', 'C', 'D.bak'], dir.children.map(&:basename).map(&:to_s).sort
        assert_equal ['A', 'C', 'B'], BatchConnect::Session.all.map(&:id)
        assert_equal ['A', 'B', 'C', 'D.bak'], dir.children.map(&:basename).map(&:to_s).sort
      end
    end

    test 'default job name uses / as delimiter' do
      BatchConnect::Session.any_instance.stubs(:adapter).returns(OodCore::Job::Adapter.new)
      BatchConnect::Session.any_instance.stubs(:token).returns('rstudio')
      BatchConnect::Session.any_instance.stubs(:staged_root).returns(Pathname.new('/dev/null'))

      with_modified_env(OOD_PORTAL: 'ood', RAILS_RELATIVE_URL_ROOT: '/pun/sys/dashboard') do
        assert_equal 'ood/sys/dashboard/rstudio', BatchConnect::Session.new.script_options[:job_name]
      end
    end

    test 'job name replaces / with - when sanitizing' do
      BatchConnect::Session.any_instance.stubs(:adapter).returns(OodCore::Job::Adapter.new)
      BatchConnect::Session.any_instance.stubs(:token).returns('rstudio')
      BatchConnect::Session.any_instance.stubs(:staged_root).returns(Pathname.new('/dev/null'))

      with_modified_env(OOD_PORTAL: 'ood', RAILS_RELATIVE_URL_ROOT: '/pun/sys/dashboard',
                        OOD_JOB_NAME_ILLEGAL_CHARS: '/') do
        assert_equal 'ood-sys-dashboard-rstudio', BatchConnect::Session.new.script_options[:job_name]
      end
    end

    test 'cache_completed can be set to true' do
      session = BatchConnect::Session.new

      refute session.cache_completed
      refute BatchConnect::Session.new.as_json['cache_completed']

      session.cache_completed = true

      assert session.cache_completed
      assert BatchConnect::Session.new.from_json(session.to_json).cache_completed
    end

    test 'update_cache_completed! will update record for completed job' do
      # TODO: add integration test to verify adapter#info is called only once
      # in consecutive get requests
      # because cached the completed status
      #
      adapter = mock
      adapter.stubs(:info).returns(OodCore::Job::Info.new(id: '123', status: :completed))
      BatchConnect::Session.any_instance.stubs(:adapter).returns(adapter)

      Dir.mktmpdir('dbroot') do |dir|
        dir = Pathname.new(dir)
        BatchConnect::Session.stubs(:db_root).returns(dir)

        dir.join('A').write({ id: 'A', job_id: '123', created_at: 100, cluster_id: 'owens' }.to_json)

        session = BatchConnect::Session.all.first

        refute session.cache_completed

        session.update_cache_completed!

        assert session.completed?, 'mock adapter should return job with completed Info status'
        assert session.cache_completed, 'update_cache_completed! failed to set cache_completed to true'
        assert BatchConnect::Session.all.first.cache_completed,
               'update_cache_completed! failed to write cache_completed to json'
      end
    end

    test 'session correctly sets cluster_id from the form' do
      BatchConnect::Session.any_instance.stubs(:stage).returns(true)
      BatchConnect::Session.any_instance.stubs(:submit).returns(true)
      BatchConnect::SessionContext.any_instance.stubs(:cluster).returns('owens')
      BatchConnect::App.any_instance.stubs(:submit_opts).returns({})

      app = BatchConnect::App.from_token('dev/test')
      session = BatchConnect::Session.new

      session.save(app: app, context: BatchConnect::SessionContext.new)
      assert_equal 'owens', session.cluster_id
    end

    test 'session correctly sets cluster_id from the sumit options' do
      BatchConnect::Session.any_instance.stubs(:stage).returns(true)
      BatchConnect::Session.any_instance.stubs(:submit).returns(true)
      BatchConnect::App.any_instance.stubs(:submit_opts).returns({ :cluster => 'owens' })

      app = BatchConnect::App.from_token('dev/test')
      session = BatchConnect::Session.new

      session.save(app: app, context: BatchConnect::SessionContext.new)
      assert_equal 'owens', session.cluster_id
    end

    test 'session throws exception when no cluster is available' do
      app = BatchConnect::App.from_token('dev/test')
      session = BatchConnect::Session.new

      save = session.save(app: app, context: BatchConnect::SessionContext.new)
      assert_equal false, save
      assert_equal I18n.t('dashboard.batch_connect_missing_cluster'), session.errors[:save].first
    end

    test 'session returns connection info from info.ood_connection_info' do
      connect = {
        :host     => 'some.host.edu',
        :port     => 8080,
        :password => 'superSecretPassword'
      }
      info = OodCore::Job::Info.new(
        id:     'test-123',
        status: :running
      )
      BatchConnect::Session.any_instance.stubs(:info).returns(info)
      OodCore::Job::Info.any_instance.stubs(:ood_connection_info).returns(connect)
      session = BatchConnect::Session.new

      # holds the right connection info
      assert session.connection_in_info?
      assert_equal session.connect.to_h, connect
    end

    test 'queued sessions with ood connection info are starting when there is connect info' do
      connect = {
        :host     => 'some.host.edu',
        :port     => 8080,
        :password => 'superSecretPassword'
      }
      info = OodCore::Job::Info.new(
        id:     'test-123',
        status: :queued
      )
      BatchConnect::Session.any_instance.stubs(:info).returns(info)
      OodCore::Job::Info.any_instance.stubs(:ood_connection_info).returns(connect)
      session = BatchConnect::Session.new

      # starting should be queued + non empty ood_connection_info
      assert session.connection_in_info?
      assert session.starting?
      assert session.queued?
      assert_equal session.connect.to_h, connect
    end

    test 'queued sessions with connection in info are not starting when there is no connect info' do
      # this is the important bit. The BatchConnect::Session has to call to_h.compact to get an
      # empty hash because the connect info has nil keys.
      connect = { host: nil }
      info = OodCore::Job::Info.new(
        id:     'test-123',
        status: :queued
      )
      BatchConnect::Session.any_instance.stubs(:info).returns(info)
      OodCore::Job::Info.any_instance.stubs(:ood_connection_info).returns(connect)
      session = BatchConnect::Session.new
      session.stage(bc_jupyter_app, context: bc_jupyter_app.build_session_context)

      assert session.connection_in_info?
      assert !session.starting?
      assert session.queued?
      assert_equal session.connect.to_h, connect
    end

    test 'session is starting? when info.running but no connection.yml' do
      Dir.mktmpdir('staged_root') do |dir|
        info = OodCore::Job::Info.new(
          id:     'test-123',
          status: :running
        )
        OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))
        BatchConnect::Session.any_instance.stubs(:id).returns('test-id')
        BatchConnect::Session.any_instance.stubs(:info).returns(info)
        session = BatchConnect::Session.new
        session.stage(bc_jupyter_app, context: bc_jupyter_app.build_session_context)

        assert !session.connection_in_info?
        assert session.starting?
      end
    end

    test 'session is running? when info.running and connection.yml exists' do
      Dir.mktmpdir('staged_root') do |dir|
        info = OodCore::Job::Info.new(
          id:     'test-123',
          status: :running,
          native: {}
        )
        connect = {
          'host'     => 'some.host.edu',
          'port'     => 8080,
          'password' => 'superSecretPassword'
        }
        OodAppkit.stubs(:dataroot).returns(Pathname.new(dir.to_s))
        session = BatchConnect::Session.new
        session.stubs(:id).returns('test-id')
        session.stubs(:info).returns(info)

        session.stage(bc_jupyter_app, context: bc_jupyter_app.build_session_context)

        File.open(session.connect_file, 'w') { |file| file.write(connect.to_yaml) }

        assert session.running?
        assert_equal session.connect.to_h, connect.symbolize_keys
      end
    end

    test 'session is running? when info.running and connection.yml does not exist' do
      info = OodCore::Job::Info.new(
        id:     'test-123',
        status: :running,
        native: {}
      )

      OodAppkit.stubs(:dataroot).returns(Pathname.new('/dev/null'))
      session = BatchConnect::Session.new
      session.stubs(:id).returns('test-id')
      session.stubs(:info).returns(info)
      # session.stage(app: bc_jupyter_app, context: bc_jupyter_app.build_session_context)

      assert !session.running?
      assert_equal session.connect.to_h, {}
    end

    test 'staged_root does not exist until we call session.stage' do
      Dir.mktmpdir('staged_root') do |dir|
        OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))
        BatchConnect::Session.any_instance.stubs(:id).returns('test-id')
        OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))
        session = BatchConnect::Session.new

        assert !Dir.exist?(session.staged_root)
        session.stage(bc_jupyter_app, context: bc_jupyter_app.build_session_context)
        assert Dir.exist?(session.staged_root)
      end
    end

    test 'ssh_to_compute_node? default' do
      session = BatchConnect::Session.new
      session.stubs(:cluster).returns(OodCore::Cluster.new({ id: 'owens', job: { foo: 'bar' } }))
      assert session.ssh_to_compute_node?
    end

    test 'ssh_to_compute_node? disabled by cluster' do
      session = BatchConnect::Session.new
      session.stubs(:cluster).returns(OodCore::Cluster.new({ id: 'owens', job: { foo: 'bar' },
  batch_connect: { ssh_allow: false } }))
      Configuration.stubs(:ood_bc_ssh_to_compute_node).returns(true)
      refute session.ssh_to_compute_node?
    end

    test 'ssh_to_compute_node? disabled globally' do
      session = BatchConnect::Session.new
      session.stubs(:token).returns('rstudio')
      session.stubs(:cluster).returns(OodCore::Cluster.new({ id: 'owens', job: { foo: 'bar' } }))
      Configuration.stubs(:ood_bc_ssh_to_compute_node).returns(false)
      refute session.ssh_to_compute_node?
    end

    test 'ssh_to_compute_node? disabled globally allowed for cluster and app' do
      session = BatchConnect::Session.new
      session.stubs(:token).returns('rstudio')
      session.stubs(:cluster).returns(OodCore::Cluster.new({ id: 'owens', job: { foo: 'bar' },
  batch_connect: { ssh_allow: true } }))
      session.stubs(:app_ssh_to_compute_node).returns(true)
      Configuration.stubs(:ood_bc_ssh_to_compute_node).returns(false)
      assert session.ssh_to_compute_node?
    end

    test 'ssh_to_compute_node? disabled globally allowed for cluster but not app' do
      session = BatchConnect::Session.new
      session.stubs(:token).returns('rstudio')
      session.stubs(:cluster).returns(OodCore::Cluster.new({ id: 'owens', job: { foo: 'bar' },
  batch_connect: { ssh_allow: true } }))
      session.stubs(:app_ssh_to_compute_node).returns(false)
      Configuration.stubs(:ood_bc_ssh_to_compute_node).returns(false)
      refute session.ssh_to_compute_node?
    end

    test 'ssh_to_compute_node? disabled globally disabled for cluster but allowed for app' do
      session = BatchConnect::Session.new
      session.stubs(:token).returns('rstudio')
      session.stubs(:cluster).returns(OodCore::Cluster.new({ id: 'owens', job: { foo: 'bar' },
  batch_connect: { ssh_allow: false } }))
      session.stubs(:app_ssh_to_compute_node).returns(true)
      Configuration.stubs(:ood_bc_ssh_to_compute_node).returns(false)
      refute session.ssh_to_compute_node?
    end

    test 'ssh_to_compute_node? handles non-existant cluster and disabled globally' do
      session = BatchConnect::Session.new
      session.stubs(:token).returns('rstudio')
      session.stubs(:cluster).raises(BatchConnect::Session::ClusterNotFound, 'Session specifies nonexistent')
      Configuration.stubs(:ood_bc_ssh_to_compute_node).returns(false)
      refute session.ssh_to_compute_node?
    end

    test 'saves the cluster id in the staged_root path' do
      # stub open3 and system apps because :save stages and submits the job
      # and expects certain things - like a valid cluster.d directory
      stub_sys_apps
      Open3.stubs(:capture3).returns(['the-job-id', '', exit_success])

      with_modified_env({ OOD_PER_CLUSTER_DATAROOT: 'true' }) do
        Dir.mktmpdir('staged_root') do |dir|
          OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))

          session = BatchConnect::Session.new
          ctx = bc_jupyter_app.build_session_context
          ctx.attributes = { 'cluster' => 'owens' }

          assert session.save(app: bc_jupyter_app, context: ctx), session.errors.each(&:to_s).to_s
          base_dir = Pathname.new("#{dir}/batch_connect/owens/bc_jupyter/output")
          assert base_dir.directory?
          assert_equal 1, base_dir.children.size
          refute File.directory?("#{dir}/batch_connect/oakley/bc_jupyter/output")

          # now let's switch to the oakley cluster
          ctx.attributes = { 'cluster' => 'oakley' }
          assert session.save(app: bc_jupyter_app, context: ctx)
          base_dir = Pathname.new("#{dir}/batch_connect/oakley/bc_jupyter/output")
          assert base_dir.directory?
          assert_equal 1, base_dir.children.size
        end
      end
    end

    test 'no cluster in dataroot by default' do
      stub_sys_apps
      Open3.stubs(:capture3).returns(['the-job-id', '', exit_success])

      Dir.mktmpdir('staged_root') do |dir|
        OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))

        session = BatchConnect::Session.new
        ctx = bc_jupyter_app.build_session_context
        ctx.attributes = { 'cluster' => 'owens' }

        assert session.save(app: bc_jupyter_app, context: ctx), session.errors.each(&:to_s).to_s
        # owens is not here in the path
        base_dir = Pathname.new("#{dir}/batch_connect/bc_jupyter/output")
        assert base_dir.directory?
        assert_equal 1, base_dir.children.size
      end
    end

    test 'writes db file correctly' do
      stub_sys_apps
      Open3.stubs(:capture3).returns(['the-job-id', '', exit_success])

      Dir.mktmpdir('test_dir') do |dir|
        OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))
        SecureRandom.stubs(:uuid).returns('test_id')

        session = BatchConnect::Session.new
        ctx = bc_jupyter_app.build_session_context
        ctx.attributes = { 'cluster' => 'owens' }

        now = Time.now
        expected_file = {
          'id'              => 'test_id',
          'cluster_id'      => 'owens',
          'job_id'          => 'the-job-id',
          'created_at'      => now.to_i,
          'token'           => 'bc_jupyter',
          'title'           => 'Jupyter Notebook',
          'script_type'     => 'basic',
          'cache_completed' => nil,
          'completed_at'    => nil
        }
        Timecop.freeze(now) do
          assert session.save(app: bc_jupyter_app, context: ctx), session.errors.each(&:to_s).to_s

          db_dir = Pathname.new("#{dir}/batch_connect/db")
          assert db_dir.directory?
          assert_equal 1, db_dir.children.size
          assert_equal ["#{db_dir}/test_id"], db_dir.children.map(&:to_s)
          assert_equal(expected_file, JSON.parse(File.read("#{db_dir}/test_id")).to_h)
          assert_equal('100600', File.stat("#{db_dir}/test_id").mode.to_s(8))
        end
      end
    end

    test 'writes user_defined_context file correctly' do
      stub_sys_apps
      Open3.stubs(:capture3).returns(['the-job-id', '', exit_success])

      Dir.mktmpdir('test_dir') do |dir|
        OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))
        SecureRandom.stubs(:uuid).returns('test_id')

        session = BatchConnect::Session.new
        ctx = bc_jupyter_app.build_session_context
        # Some attribute overrides
        ctx.attributes = { 'cluster' => 'owens', 'bc_num_hours' => 100, 'cuda_version' => 'cuda_100' }

        expected_user_context = {
          'cluster'                    => 'owens',
          'bc_num_hours'               => '100',
          'bc_num_slots'               => '1',
          'mode'                       => '1',
          'node_type'                  => '',
          'gpus'                       => '0',
          'bc_account'                 => '',
          'bc_account_other'           => '',
          'bc_email_on_started'        => '',
          'python_version'             => '',
          'cuda_version'               => 'cuda_100',
          'hidden_change_thing'        => 'default',
          'classroom'                  => '',
          'classroom_size'             => '',
          'advanced_options'           => '',
          'auto_modules_app_jupyter'   => '',
          'auto_modules_intel'         => '',
          'auto_modules_netcdf_serial' => '',
          'checkbox_test'              => '',
          'gpus_num_v100'              => ''
        }

        assert session.save(app: bc_jupyter_app, context: ctx), session.errors.each(&:to_s).to_s

        assert session.user_defined_context_file.exist?
        assert_equal expected_user_context, session.user_context
      end
    end

    test 'destroy should should delete db file' do
      BatchConnect::Session.any_instance.stubs(:adapter).returns(stub(delete: nil,
                                                                      info:   OodCore::Job::Info.new(
                                                                        id: '1234', status: :running
                                                                      )))
      BatchConnect::Session.any_instance.stubs(:info).returns(OodCore::Job::Info.new(id: '1234', status: :running))
      Dir.mktmpdir('test_dir') do |dir|
        dir = Pathname.new(dir)
        BatchConnect::Session.stubs(:db_root).returns(dir)
        session_id = 'test_id'

        dir.join(session_id).write({ id: session_id, job_id: '1234', created_at: 100, cluster_id: 'owens' }.to_json)

        assert BatchConnect::Session.exist?(session_id)
        session = BatchConnect::Session.find(session_id)
        session.destroy
        refute BatchConnect::Session.exist?(session_id)
      end
    end

    test 'cancel should not should delete db file and persist cache_completed flag' do
      BatchConnect::Session.any_instance.stubs(:adapter).returns(stub(delete: nil,
                                                                      info:   OodCore::Job::Info.new(
                                                                        id: '1234', status: :running
                                                                      )))
      Dir.mktmpdir('test_dir') do |dir|
        dir = Pathname.new(dir)
        BatchConnect::Session.stubs(:db_root).returns(dir)
        session_id = 'test_id'

        dir.join(session_id).write({ id: session_id, job_id: '1234', created_at: 100, cluster_id: 'owens' }.to_json)

        assert BatchConnect::Session.exist?(session_id)
        session = BatchConnect::Session.find(session_id)
        refute session.cache_completed
        session.cancel

        assert session.completed?
        assert BatchConnect::Session.exist?(session_id)
        assert BatchConnect::Session.find(session_id).cache_completed
      end
    end

    test 'completed? should be true when queued? is true and session is canceled' do
      session = create_session(status: :queued)
      assert_equal false, session.completed?
      assert_equal true, session.queued?

      session.cancel
      assert_equal true, session.completed?
    end

    test 'completed? should be true when held? is true and session is canceled' do
      session = create_session(status: :queued_held)
      assert_equal false, session.completed?
      assert_equal true, session.held?

      session.cancel
      assert_equal true, session.completed?
    end

    test 'completed? should be true when suspended? is true and session is canceled' do
      session = create_session(status: :suspended)
      assert_equal false, session.completed?
      assert_equal true, session.suspended?

      session.cancel
      assert_equal true, session.completed?
    end

    test 'completed? should be true when starting? is true and session is canceled' do
      session = create_session(status: :running, connect_file: false)
      assert_equal false, session.completed?
      assert_equal true, session.starting?

      session.cancel
      assert_equal true, session.completed?
    end

    test 'completed? should be true when running? is true and session is canceled' do
      session = create_session(status: :running, connect_file: true)
      assert_equal false, session.completed?
      assert_equal true, session.running?

      session.cancel
      assert_equal true, session.completed?
    end

    test 'default bc days old is set to 7' do
      assert_equal 7, BatchConnect::Session.old_in_days
    end

    test 'can configure bc days old' do
      with_modified_env({ OOD_BC_CARD_TIME: '3' }) do
        assert_equal 3, BatchConnect::Session.old_in_days
      end

      with_modified_env({ OOD_BC_CARD_TIME: '0' }) do
        assert_equal 0, BatchConnect::Session.old_in_days
      end
    end

    test 'return 0 if bc days old is less than 0' do
      with_modified_env({ OOD_BC_CARD_TIME: '-1' }) do
        assert_equal 0, BatchConnect::Session.old_in_days
      end
    end

    test 'return correct values if bc days old cant be converted to integer' do
      with_modified_env({ OOD_BC_CARD_TIME: 'three' }) do
        assert_equal 7, BatchConnect::Session.old_in_days
      end

      with_modified_env({ OOD_BC_CARD_TIME: '3three' }) do
        assert_equal 3, BatchConnect::Session.old_in_days
      end

      with_modified_env({ OOD_BC_CARD_TIME: '+3three' }) do
        assert_equal 3, BatchConnect::Session.old_in_days
      end

      with_modified_env({ OOD_BC_CARD_TIME: '-3three' }) do
        assert_equal 0, BatchConnect::Session.old_in_days
      end
    end

    def create_session(status: nil, connect_file: false)
      session_id = SecureRandom.uuid
      job_id = SecureRandom.uuid
      session = BatchConnect::Session.new.from_json({ id: session_id, job_id: job_id, created_at: 100,
  cluster_id: 'owens' }.to_json)
      session.stubs(:adapter).returns(stub(delete: nil,
                                           info:   OodCore::Job::Info.new(
                                             id: job_id, status: status.to_sym
                                           )))
      session.stubs(:connect_file).returns(stub(file?: connect_file))
      session.stubs(:db_file).returns(stub(write: nil))
      session
    end
  end
end
