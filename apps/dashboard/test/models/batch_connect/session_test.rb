require 'test_helper'

class BatchConnect::SessionTest < ActiveSupport::TestCase
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
      Timecop.freeze(8.days.from_now) do
        assert session.old?, "A session unmodified for 8 days should be identified as old"
      end
    end
  end

  def create_double_session
    # FIXME: we should store status in the job, and then fix info to return an info object with id and status
    Class.new(BatchConnect::Session) do
      def completed?
        job_id == "COMPLETED"
      end
    end
  end

  #FIXME: this tests too many things:
  # 1. the order of the sessions based on the created_at date
  # 2. that bad sessions are renamed to .bak and the omitted from the original
  # 3. a job 8 days
  test "should only return sorted running and recently completed sessions from dbroot and clean up old completed or corrupt session files" do
    # FIXME: we have mocha
    double_session = create_double_session

    Dir.mktmpdir("dbroot") do |dir|
      dir = Pathname.new(dir)
      double_session.stubs(:db_root).returns(dir)

      [
        { id: "A", job_id: "RUNNING",   created_at: 500 },
        { id: "B", job_id: "RUNNING",   created_at: 100 },
        { id: "C", job_id: "RUNNING",   created_at: 300 },
        { id: "D", job_id: "COMPLETED", created_at: 400 },
        { id: "E", job_id: "COMPLETED", created_at: 400 },
      ].each { |v| File.write dir.join(v[:id]), v.to_json }


      # the final job is 8 days old so will be deleted
      File.utime(8.days.ago.to_i, 8.days.ago.to_i, dir.join("E"))

      File.write dir.join("bad1"), ""
      File.write dir.join("bad2"), "{)"

      assert_equal ["A", "B", "C", "D", "E", "bad1", "bad2"], dir.children.map(&:basename).map(&:to_s).sort
      sessions = double_session.all
      assert_equal ["A", "D", "C", "B"], sessions.map(&:id)
      assert_equal ["A", "B", "C", "D", "bad1.bak", "bad2.bak"], dir.children.map(&:basename).map(&:to_s).sort
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
end
