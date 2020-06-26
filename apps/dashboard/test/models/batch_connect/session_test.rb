require 'test_helper'

class BatchConnect::SessionTest < ActiveSupport::TestCase
  test "should return no sessions if dbroot is empty" do
    Dir.mktmpdir("dbroot") do |dir|
      dir = Pathname.new(dir)
      BatchConnect::Session.stubs(:db_root).returns(dir)

      assert_equal [], BatchConnect::Session.all
    end
  end

  test "should only return sorted running sessions from dbroot and clean up completed/corrupt session files" do
    double_session = Class.new(BatchConnect::Session) do
      def completed?
        job_id == "COMPLETED"
      end
    end

    Dir.mktmpdir("dbroot") do |dir|
      dir = Pathname.new(dir)
      double_session.stubs(:db_root).returns(dir)

      [
        { id: "A", job_id: "RUNNING",   created_at: 500 },
        { id: "B", job_id: "RUNNING",   created_at: 100 },
        { id: "C", job_id: "RUNNING",   created_at: 300 },
        { id: "D", job_id: "COMPLETED", created_at: 400 }
      ].each do |v|
        File.open(dir.join(v[:id]), "w") do |f|
          f.write v.to_json
        end
      end
      File.open(dir.join("bad1"), "w") do |f|
        f.write("")
      end
      File.open(dir.join("bad2"), "w") do |f|
        f.write("{)")
      end

      assert_equal ["A", "B", "C", "D", "bad1", "bad2"], dir.children.map(&:basename).map(&:to_s).sort
      sessions = double_session.all
      assert_equal ["A", "C", "B"], sessions.map(&:id)
      assert_equal ["A", "B", "C", "bad1.bak", "bad2.bak"], dir.children.map(&:basename).map(&:to_s).sort
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

  test "session correctly sets cluster_id from the form" do
    BatchConnect::SessionContext.any_instance.stubs(:cluster).returns('owens')

    session = BatchConnect::Session.new
    session.send(:set_cluster_id, BatchConnect::SessionContext.new, {})
    assert_equal 'owens', session.cluster_id
  end

  test "session correctly sets cluster_id from the sumit options" do
    session = BatchConnect::Session.new
    session.send(:set_cluster_id, BatchConnect::SessionContext.new, {:cluster => 'owens'})
    assert_equal 'owens', session.cluster_id
  end

  test "session throws exception when no cluster is available" do
    assert_raise BatchConnect::Session::ClusterNotFound do
      BatchConnect::Session.new.send(:set_cluster_id, BatchConnect::SessionContext.new, {})
    end
  end
end
