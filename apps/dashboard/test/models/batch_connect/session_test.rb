require 'test_helper'

class BatchConnect::SessionTest < ActiveSupport::TestCase

  def bc_jupyter_app
    r = PathRouter.new("test/fixtures/sys_with_interactive_apps/bc_jupyter")
    BatchConnect::App.new(router: r)
  end

  test "should return no sessions if dbroot is empty" do
    Dir.mktmpdir("dbroot") do |dir|
      dir = Pathname.new(dir)
      BatchConnect::Session.stubs(:db_root).returns(dir)

      assert_equal [], BatchConnect::Session.all
    end
  end

  test "old? " do
    Tempfile.open do |f|
      BatchConnect::Session.any_instance.stubs(:db_file).returns(f.path)
      BatchConnect::Session.any_instance.stubs(:id).returns(File.basename(f.path))
      session = BatchConnect::Session.new({})

      refute session.old?, "A newly created session should not be identified as old"
      Timecop.freeze((BatchConnect::Session::OLD_IN_DAYS+1).days.from_now) do
        assert session.old?, "A session unmodified for #{BatchConnect::Session::OLD_IN_DAYS+1} days should be identified as old"
      end
    end
  end

  test "days_till_old" do
    assert_equal 0, BatchConnect::Session.new.days_till_old, "should be 0 since no id is set"
    assert_equal 0, BatchConnect::Session.new(id: "A").days_till_old, "should be 0 since no db file exists"

    File.stubs(:stat).returns(OpenStruct.new(mtime: Time.now))
    assert_equal BatchConnect::Session::OLD_IN_DAYS, BatchConnect::Session.new(id: 'A').days_till_old

    File.stubs(:stat).returns(OpenStruct.new(mtime: 1.day.ago))
    assert_equal BatchConnect::Session::OLD_IN_DAYS-1, BatchConnect::Session.new(id: 'A').days_till_old
  end

  def create_double_session
    # FIXME: we should store status in the job, and then fix info to return an info object with id and status
    Class.new(BatchConnect::Session) do
      def completed?
        job_id == "COMPLETED"
      end
    end
  end

  test "Session.all should return recently completed sessions" do
    double_session = create_double_session

    Dir.mktmpdir("dbroot") do |dir|
      dir = Pathname.new(dir)
      double_session.stubs(:db_root).returns(dir)

      [
        { id: "A", job_id: "RUNNING",   created_at: 500 },
        { id: "B", job_id: "COMPLETED",   created_at: 100 }
      ].each { |v| File.write dir.join(v[:id]), v.to_json }

      sessions = double_session.all
      assert_equal ["A", "B"], sessions.map(&:id)
    end
  end

  test "Session.all should omit 'old' sessions and delete old job records" do
    double_session = create_double_session

    Dir.mktmpdir("dbroot") do |dir|
      dir = Pathname.new(dir)
      double_session.stubs(:db_root).returns(dir)

      [
        { id: "A", job_id: "RUNNING",   created_at: 100 },
        { id: "OLD", job_id: "COMPLETED",   created_at: 100 }
      ].each { |v| File.write dir.join(v[:id]), v.to_json }

      Timecop.freeze((BatchConnect::Session::OLD_IN_DAYS+1).days.from_now) do
        assert_equal ["A", "OLD"], dir.children.map(&:basename).map(&:to_s).sort
        sessions = double_session.all
        assert_equal ["A"], sessions.map(&:id)
        assert_equal ["A"], dir.children.map(&:basename).map(&:to_s).sort
      end
    end
  end

  test "Session.all should return ids order by created_at date DESC (newer to older)" do
    double_session = create_double_session

    Dir.mktmpdir("dbroot") do |dir|
      dir = Pathname.new(dir)
      double_session.stubs(:db_root).returns(dir)

      [
        { id: "A", job_id: "RUNNING",   created_at: 500 },
        { id: "B", job_id: "RUNNING",   created_at: 100 },
        { id: "C", job_id: "RUNNING",   created_at: 300 },
        { id: "D", job_id: "RUNNING", created_at: 400 },
      ].each { |v| File.write dir.join(v[:id]), v.to_json }

      sessions = double_session.all
      assert_equal ["A", "D", "C", "B"], sessions.map(&:id)
    end
  end

  test "Session.all should return completed jobs after running jobs" do
    double_session = create_double_session

    Dir.mktmpdir("dbroot") do |dir|
      dir = Pathname.new(dir)
      double_session.stubs(:db_root).returns(dir)

      [
        { id: "A", job_id: "COMPLETED",   created_at: 500 },
        { id: "B", job_id: "RUNNING",   created_at: 100 },
        { id: "C", job_id: "RUNNING",   created_at: 300 },
        { id: "D", job_id: "RUNNING", created_at: 400 }
      ].each { |v| File.write dir.join(v[:id]), v.to_json }

      sessions = double_session.all
      assert_equal ["D", "C", "B", "A"], sessions.map(&:id), "even though A is newest, since completed, it should appear last"
    end
  end

  test "Session.all should rename and ignore corrupt session files" do
    # FIXME: this is a test to confirm how it currently works - but how is wrong
    # Session.all is a "getter" method - **it should not change state as it does**

    double_session = create_double_session
    Dir.mktmpdir("dbroot") do |dir|
      dir = Pathname.new(dir)
      double_session.stubs(:db_root).returns(dir)

      [
        { id: "A", job_id: "RUNNING",   created_at: 500 },
      ].each { |v| File.write dir.join(v[:id]), v.to_json }

      File.write dir.join("bad1"), ""
      File.write dir.join("bad2"), "{)"

      assert_equal ["A", "bad1", "bad2"], dir.children.map(&:basename).map(&:to_s).sort
      sessions = double_session.all
      assert_equal ["A"], sessions.map(&:id)
      assert_equal ["A", "bad1.bak", "bad2.bak"], dir.children.map(&:basename).map(&:to_s).sort
    end
  end

  test "should ignore *.bak files in dbroot even if valid" do
    Dir.mktmpdir("dbroot") do |dir|
      dir = Pathname.new(dir)
      BatchConnect::Session.stubs(:db_root).returns(dir)
      BatchConnect::Session.any_instance.stubs(:completed?).returns(false)

      [
        { id: "A", created_at: 500 },
        { id: "B", created_at: 100 },
        { id: "C", created_at: 300 }
      ].each do |v|
        File.open(dir.join(v[:id]), "w") do |f|
          f.write v.to_json
        end
      end
      File.open(dir.join("D.bak"), "w") do |f|
        f.write({ id: "D", created_at: 400 }.to_json)
      end

      assert_equal ["A", "B", "C", "D.bak"], dir.children.map(&:basename).map(&:to_s).sort
      assert_equal ["A", "C", "B"], BatchConnect::Session.all.map(&:id)
      assert_equal ["A", "B", "C", "D.bak"], dir.children.map(&:basename).map(&:to_s).sort
    end
  end

  test "default job name uses / as delimiter" do
    BatchConnect::Session.any_instance.stubs(:adapter).returns(OodCore::Job::Adapter.new)
    BatchConnect::Session.any_instance.stubs(:token).returns('rstudio')
    BatchConnect::Session.any_instance.stubs(:staged_root).returns(Pathname.new("/dev/null"))

    with_modified_env(OOD_PORTAL: 'ood', RAILS_RELATIVE_URL_ROOT: '/pun/sys/dashboard') do
      assert_equal 'ood/sys/dashboard/rstudio', BatchConnect::Session.new.script_options[:job_name]
    end
  end

  test "job name replaces / with - when sanitizing" do
    BatchConnect::Session.any_instance.stubs(:adapter).returns(OodCore::Job::Adapter.new)
    BatchConnect::Session.any_instance.stubs(:token).returns('rstudio')
    BatchConnect::Session.any_instance.stubs(:staged_root).returns(Pathname.new("/dev/null"))

    with_modified_env(OOD_PORTAL: 'ood', RAILS_RELATIVE_URL_ROOT: '/pun/sys/dashboard', OOD_JOB_NAME_ILLEGAL_CHARS: '/') do
      assert_equal 'ood-sys-dashboard-rstudio', BatchConnect::Session.new.script_options[:job_name]
    end
  end

  test "cache_completed can be set to true" do
    session = BatchConnect::Session.new

    refute session.cache_completed
    refute BatchConnect::Session.new.as_json['cache_completed']

    session.cache_completed = true

    assert session.cache_completed
    assert BatchConnect::Session.new.from_json(session.to_json).cache_completed
  end

  test "update_cache_completed! will update record for completed job" do
    # TODO: add integration test to verify adapter#info is called only once
    # in consecutive get requests
    # because cached the completed status
    #
    adapter = mock()
    adapter.stubs(:info).returns(OodCore::Job::Info.new(id: "123", status: :completed))
    BatchConnect::Session.any_instance.stubs(:adapter).returns(adapter)

    Dir.mktmpdir("dbroot") do |dir|
      dir = Pathname.new(dir)
      BatchConnect::Session.stubs(:db_root).returns(dir)

      dir.join("A").write({id: "A", job_id: "123", created_at: 100 }.to_json)

      session = BatchConnect::Session.all.first

      refute session.cache_completed

      session.update_cache_completed!

      assert session.completed?, "mock adapter should return job with completed Info status"
      assert session.cache_completed, "update_cache_completed! failed to set cache_completed to true"
      assert BatchConnect::Session.all.first.cache_completed, "update_cache_completed! failed to write cache_completed to json"
    end
  end

  test "session correctly sets cluster_id from the form" do
    BatchConnect::Session.any_instance.stubs(:stage).returns(true)
    BatchConnect::Session.any_instance.stubs(:submit).returns(true)
    BatchConnect::SessionContext.any_instance.stubs(:cluster).returns('owens')
    BatchConnect::App.any_instance.stubs(:submit_opts).returns({})

    app = BatchConnect::App.from_token("dev/test")
    session = BatchConnect::Session.new

    session.save(app: app, context: BatchConnect::SessionContext.new)
    assert_equal 'owens', session.cluster_id
  end

  test "session correctly sets cluster_id from the sumit options" do
    BatchConnect::Session.any_instance.stubs(:stage).returns(true)
    BatchConnect::Session.any_instance.stubs(:submit).returns(true)
    BatchConnect::App.any_instance.stubs(:submit_opts).returns({:cluster => 'owens'})

    app = BatchConnect::App.from_token("dev/test")
    session = BatchConnect::Session.new

    session.save(app: app, context: BatchConnect::SessionContext.new)
    assert_equal 'owens', session.cluster_id
  end

  test "session throws exception when no cluster is available" do
    app = BatchConnect::App.from_token("dev/test")
    session = BatchConnect::Session.new

    save = session.save(app: app, context: BatchConnect::SessionContext.new)
    assert_equal false, save
    assert_equal I18n.t('dashboard.batch_connect_missing_cluster'), session.errors[:save].first
  end

  test "session returns connection info from info.ood_connection_info" do
    connect = {
      :host => 'some.host.edu',
      :port => 8080,
      :password => 'superSecretPassword'
    }
    info = OodCore::Job::Info.new(
        id: 'test-123',
        status: :running
      )
    BatchConnect::Session.any_instance.stubs(:info).returns(info)
    OodCore::Job::Info.any_instance.stubs(:ood_connection_info).returns(connect)
    session = BatchConnect::Session.new

    # holds the right connection info
    assert session.connection_in_info?
    assert_equal session.connect.to_h, connect
  end

  test "queued sessions with ood connection info are starting when there is connect info" do
    connect = {
      :host => 'some.host.edu',
      :port => 8080,
      :password => 'superSecretPassword'
    }
    info = OodCore::Job::Info.new(
        id: 'test-123',
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

  test "queued sessions with connection in info are not starting when there is no connect info" do
    # this is the important bit. The BatchConnect::Session has to call to_h.compact to get an
    # empty hash because the connect info has nil keys.
    connect = { host: nil }
    info = OodCore::Job::Info.new(
        id: 'test-123',
        status: :queued,
      )
    BatchConnect::Session.any_instance.stubs(:info).returns(info)
    OodCore::Job::Info.any_instance.stubs(:ood_connection_info).returns(connect)
    OodAppkit.stubs(:clusters).returns([OodCore::Cluster.new({id: 'owens', job: {foo: 'bar'}})])
    session = BatchConnect::Session.new
    session.stage(app: bc_jupyter_app, context: bc_jupyter_app.build_session_context)

    assert session.connection_in_info?
    assert !session.starting?
    assert session.queued?
    assert_equal session.connect.to_h, connect
  end

  test "session is starting? when info.running but no connection.yml" do
    Dir.mktmpdir("staged_root") do |dir|
      info = OodCore::Job::Info.new(
        id: 'test-123',
        status: :running
      )
      BatchConnect::Session.stubs(:dataroot).returns(Pathname.new(dir))
      BatchConnect::Session.any_instance.stubs(:id).returns('test-id')
      BatchConnect::Session.any_instance.stubs(:info).returns(info)
      OodAppkit.stubs(:clusters).returns([OodCore::Cluster.new({id: 'owens', job: {foo: 'bar'}})])
      session = BatchConnect::Session.new
      session.stage(app: bc_jupyter_app, context: bc_jupyter_app.build_session_context)

      assert !session.connection_in_info?
      assert session.starting?
    end
  end

  test "session is running? when info.running and connection.yml exists" do
    Dir.mktmpdir("staged_root") do |dir|
      info = OodCore::Job::Info.new(
        id: 'test-123',
        status: :running,
        native: {}
      )
      connect = {
        'host' => 'some.host.edu',
        'port' => 8080,
        'password' => 'superSecretPassword'
      }
      BatchConnect::Session.stubs(:dataroot).returns(Pathname.new(dir.to_s))
      BatchConnect::Session.any_instance.stubs(:id).returns('test-id')
      BatchConnect::Session.any_instance.stubs(:info).returns(info)
      OodAppkit.stubs(:clusters).returns([OodCore::Cluster.new({id: 'owens', job: {foo: 'bar'}})])
      session = BatchConnect::Session.new
      session.stage(app: bc_jupyter_app, context: bc_jupyter_app.build_session_context)

      File.open(session.connect_file, 'w') { |file| file.write(connect.to_yaml) }

      assert session.running?
      assert_equal session.connect.to_h, connect.symbolize_keys
    end
  end

  test "staged_root does not exist until we call session.stage" do
    Dir.mktmpdir("staged_root") do |dir|
      BatchConnect::Session.stubs(:dataroot).returns(Pathname.new(dir))
      BatchConnect::Session.any_instance.stubs(:id).returns('test-id')
      OodAppkit.stubs(:clusters).returns([OodCore::Cluster.new({id: 'owens', job: {foo: 'bar'}})])
      session = BatchConnect::Session.new

      assert !Dir.exist?(session.staged_root)
      session.stage(app: bc_jupyter_app, context: bc_jupyter_app.build_session_context)
      assert Dir.exist?(session.staged_root)
    end
  end

  test "ssh_to_compute_node? default" do
    session = BatchConnect::Session.new
    session.stubs(:cluster).returns(OodCore::Cluster.new({id: 'owens', job: {foo: 'bar'}}))
    assert session.ssh_to_compute_node?
  end

  test "ssh_to_compute_node? disabled by cluster" do
    session = BatchConnect::Session.new
    session.stubs(:cluster).returns(OodCore::Cluster.new({id: 'owens', job: {foo: 'bar'}, batch_connect: {ssh_allow: false}}))
    Configuration.stubs(:ood_bc_ssh_to_compute_node).returns(true)
    refute session.ssh_to_compute_node?
  end

  test "ssh_to_compute_node? disabled globally" do
    session = BatchConnect::Session.new
    session.stubs(:cluster).returns(OodCore::Cluster.new({id: 'owens', job: {foo: 'bar'}}))
    Configuration.stubs(:ood_bc_ssh_to_compute_node).returns(false)
    refute session.ssh_to_compute_node?
  end
end
