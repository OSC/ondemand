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

      Timecop.freeze do
        File.stubs(:stat).returns(OpenStruct.new(mtime: Time.now))
        assert_equal BatchConnect::Session.old_in_days, BatchConnect::Session.new(id: 'A').days_till_old

        File.stubs(:stat).returns(OpenStruct.new(mtime: 1.day.ago))
        assert_equal BatchConnect::Session.old_in_days - 1, BatchConnect::Session.new(id: 'A').days_till_old
      end
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
      Configuration.stubs(:bc_ssh_to_compute_node).returns(true)
      refute session.ssh_to_compute_node?
    end

    test 'ssh_to_compute_node? disabled globally' do
      session = BatchConnect::Session.new
      session.stubs(:token).returns('rstudio')
      session.stubs(:cluster).returns(OodCore::Cluster.new({ id: 'owens', job: { foo: 'bar' } }))
      Configuration.stubs(:bc_ssh_to_compute_node).returns(false)
      refute session.ssh_to_compute_node?
    end

    test 'ssh_to_compute_node? disabled globally allowed for cluster and app' do
      session = BatchConnect::Session.new
      session.stubs(:token).returns('rstudio')
      session.stubs(:cluster).returns(OodCore::Cluster.new({ id: 'owens', job: { foo: 'bar' },
  batch_connect: { ssh_allow: true } }))
      session.stubs(:app_ssh_to_compute_node).returns(true)
      Configuration.stubs(:bc_ssh_to_compute_node).returns(false)
      assert session.ssh_to_compute_node?
    end

    test 'ssh_to_compute_node? disabled globally allowed for cluster but not app' do
      session = BatchConnect::Session.new
      session.stubs(:token).returns('rstudio')
      session.stubs(:cluster).returns(OodCore::Cluster.new({ id: 'owens', job: { foo: 'bar' },
  batch_connect: { ssh_allow: true } }))
      session.stubs(:app_ssh_to_compute_node).returns(false)
      Configuration.stubs(:bc_ssh_to_compute_node).returns(false)
      refute session.ssh_to_compute_node?
    end

    test 'ssh_to_compute_node? disabled globally disabled for cluster but allowed for app' do
      session = BatchConnect::Session.new
      session.stubs(:token).returns('rstudio')
      session.stubs(:cluster).returns(OodCore::Cluster.new({ id: 'owens', job: { foo: 'bar' },
  batch_connect: { ssh_allow: false } }))
      session.stubs(:app_ssh_to_compute_node).returns(true)
      Configuration.stubs(:bc_ssh_to_compute_node).returns(false)
      refute session.ssh_to_compute_node?
    end

    test 'ssh_to_compute_node? handles non-existent cluster and disabled globally' do
      session = BatchConnect::Session.new
      session.stubs(:token).returns('rstudio')
      session.stubs(:cluster).raises(BatchConnect::Session::ClusterNotFound, 'Session specifies nonexistent')
      Configuration.stubs(:bc_ssh_to_compute_node).returns(false)
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

    test 'return correct values if bc days old cannot be converted to integer' do
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

    # Sessions on clusters with a file adapter (see ood_core's OodCore::Files), whose files are on the cluster.

    CLUSTER_DATAROOT = Pathname.new('/cluster/home/me/ondemand/data/sys/dashboard')
    # One of the clusters in bc_jupyter's form, which only takes those.
    REMOTE_CLUSTER = 'owens'

    def stub_remote_cluster
      # Rendering the bc_jupyter templates needs the module data and apps of stub_sys_apps.
      stub_sys_apps
      @adapter = stub('file_adapter')
      @adapter.stubs(:dataroot).returns(CLUSTER_DATAROOT)
      remote = OodCore::Cluster.new({ id: REMOTE_CLUSTER, job: { adapter: 'slurm' },
                                      file: { adapter: 'ssh', host: 'login' } })
      remote.stubs(:file_adapter).returns(@adapter)
      local = OodCore::Cluster.new({ id: 'local', job: { adapter: 'slurm' } })
      OodAppkit.stubs(:clusters).returns(OodCore::Clusters.new([remote, local]))
      remote
    end

    def remote_session(**attributes)
      BatchConnect::Session.new.from_json({ id: 'session-id', token: 'sys/bc_jupyter', cluster_id: REMOTE_CLUSTER,
                                            job_id: 'job-id', created_at: 100 }.merge(attributes).to_json)
    end

    def running_info
      OodCore::Job::Info.new(id: 'job-id', status: :running, native: {})
    end

    test 'sessions are remote on clusters with a file adapter' do
      stub_remote_cluster

      assert remote_session.remote?
      refute remote_session(cluster_id: 'local').remote?
      refute remote_session(cluster_id: 'removed').remote?, 'sessions of clusters that are not configured are local'
    end

    test 'staged_root of a remote session is under the dataroot on the cluster' do
      stub_remote_cluster

      assert_equal CLUSTER_DATAROOT.join('batch_connect/sys/bc_jupyter/output/session-id'), remote_session.staged_root
      with_modified_env({ OOD_PER_CLUSTER_DATAROOT: 'true' }) do
        assert_equal CLUSTER_DATAROOT.join("batch_connect/#{REMOTE_CLUSTER}/sys/bc_jupyter/output/session-id"),
                     remote_session.staged_root
      end
    end

    test 'staged_root is nil with an error when the dataroot on the cluster cannot be determined' do
      stub_remote_cluster
      @adapter.stubs(:dataroot).raises(OodCore::FilesAdapterError, 'Could not determine the home directory')
      session = remote_session

      assert_nil session.staged_root
      assert_nil session.staged_root
      assert_equal ['Could not determine the home directory'], session.errors[:stage]
    end

    test 'Session.all leaves out sessions whose staged_root cannot be determined' do
      stub_remote_cluster
      @adapter.stubs(:dataroot).raises(OodCore::FilesAdapterError, 'Could not determine the home directory')
      double_session = create_double_session

      Dir.mktmpdir('dbroot') do |dir|
        dir = Pathname.new(dir)
        double_session.stubs(:db_root).returns(dir)
        OodAppkit.stubs(:dataroot).returns(dir)
        [
          { id: 'local-session', job_id: 'COMPLETED', created_at: 100, cluster_id: 'local' },
          { id: 'remote-session', job_id: 'COMPLETED', created_at: 100, cluster_id: REMOTE_CLUSTER }
        ].each { |v| File.write(dir.join(v[:id]), v.to_json) }

        assert_equal ['local-session'], double_session.all.map(&:id)
      end
    end

    test 'remote session is starting until connection.yml exists on the cluster' do
      stub_remote_cluster
      connect_file = CLUSTER_DATAROOT.join('batch_connect/sys/bc_jupyter/output/session-id/connection.yml')
      @adapter.stubs(:exist?).with(connect_file).returns(false)
      session = remote_session
      session.stubs(:info).returns(running_info)

      assert session.starting?
      refute session.running?
    end

    test 'remote session is running and reads connection.yml from the cluster' do
      stub_remote_cluster
      connect_file = CLUSTER_DATAROOT.join('batch_connect/sys/bc_jupyter/output/session-id/connection.yml')
      @adapter.stubs(:exist?).with(connect_file).returns(true)
      @adapter.stubs(:read).with(connect_file).returns({ 'host' => 'node1', 'port' => 8080 }.to_yaml)
      session = remote_session
      session.stubs(:info).returns(running_info)

      refute session.starting?
      assert session.running?
      assert_equal({ host: 'node1', port: 8080 }, session.connect.to_h)
    end

    test 'remote session takes the connection from the job info when the job adapter has it' do
      stub_remote_cluster
      info = running_info
      info.define_singleton_method(:ood_connection_info) { { host: 'pod1', port: 8080 } }
      @adapter.expects(:read).never
      session = remote_session
      session.stubs(:info).returns(info)

      assert_equal({ host: 'pod1', port: 8080 }, session.connect.to_h)
    end

    test 'stage copies the rendered templates and the user defined context to the cluster' do
      cluster = stub_remote_cluster
      session = remote_session
      staged_root = CLUSTER_DATAROOT.join('batch_connect/sys/bc_jupyter/output/session-id')
      context = bc_jupyter_app.build_session_context
      staged_files = nil
      # The staged root is created before anything is written into it.
      staging = sequence('staging')

      @adapter.expects(:mkdir).with(staged_root.to_s).in_sequence(staging)
      @adapter.expects(:write).with(staged_root.join('user_defined_context.json'),
                                    JSON.pretty_generate(context.as_json)).in_sequence(staging)
      @adapter.expects(:copy_with_progress).with do |src_fs, dest_fs, src, dst|
        staged_files = Dir.children(src).sort
        src_fs.nil? && dest_fs == cluster && dst == staged_root.to_s
      end.in_sequence(staging)

      assert session.stage(bc_jupyter_app.root.join('template'), context: context), session.errors.full_messages.to_s
      assert_equal ['.keep', 'script.sh'], staged_files
    end

    test 'stage fails with an error when copying to the cluster fails' do
      stub_remote_cluster
      session = remote_session
      @adapter.stubs(:mkdir)
      @adapter.stubs(:write)
      @adapter.stubs(:copy_with_progress).raises(StandardError, 'rsync exited with status 23')

      refute session.stage(bc_jupyter_app.root.join('template'), context: bc_jupyter_app.build_session_context)
      assert_equal ['rsync exited with status 23'], session.errors[:stage]
    end

    test 'save stages and submits a remote session, recording the job script on the cluster' do
      stub_remote_cluster
      Open3.stubs(:capture3).returns(['the-job-id', '', exit_success])
      written = {}
      @adapter.stubs(:mkdir)
      @adapter.stubs(:copy_with_progress)
      @adapter.stubs(:write).with { |path, content| written[path.basename.to_s] = content }

      Dir.mktmpdir('dataroot') do |dir|
        OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))
        session = BatchConnect::Session.new
        context = bc_jupyter_app.build_session_context
        context.attributes = { 'cluster' => REMOTE_CLUSTER }

        assert session.save(app: bc_jupyter_app, context: context), session.errors.full_messages.to_s
        assert_equal 'the-job-id', session.job_id
        assert_equal ['job_script_content.sh', 'job_script_options.json', 'user_defined_context.json'],
                     written.keys.sort
        assert_match(/script\.sh/, written['job_script_content.sh'])
        # Only the session database stays on the local file system.
        assert_equal ['db'], Pathname.new(dir).join('batch_connect').children.map { |c| c.basename.to_s }
      end
    end
  end
end
