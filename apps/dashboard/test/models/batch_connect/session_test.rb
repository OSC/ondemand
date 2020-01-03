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

  test "generated job_name should be valid for Grid Engine and PBSPro" do
    original = ENV['OOD_SANITIZE_BC_JOB_NAMES']
    ENV['OOD_SANITIZE_BC_JOB_NAMES'] = '1'

    Dir.mktmpdir("dbroot") do |dir|
      dir = Pathname.new(dir)
      BatchConnect::Session.stubs(:db_root).returns(dir)

      [
        { id: "A", job_id: "RUNNING", created_at: 500, token: 'matlab' },
        { id: "B", job_id: "RUNNING", created_at: 100, token: 'rstudio' },
        { id: "C", job_id: "RUNNING", created_at: 100, token: 'jupyter:development' },
        { id: "D", job_id: "RUNNING", created_at: 100, token: 'qgis/batch' },
      ].each do |v|
        File.open(dir.join(v[:id]), "w") do |f|
          f.write v.to_json
        end
      end

      sessions = BatchConnect::Session.all
      refute sessions.map { |session| session.send :job_name }.any? { |job_name| /[:\/]/.match?(job_name) }
    end

    ENV['OOD_SANITIZE_BC_JOB_NAMES'] = original
  end

  test "generated job_name is unchanged when OOD_SANITIZE_BC_JOB_NAMES is falsy" do
    original = ENV['OOD_SANITIZE_BC_JOB_NAMES']
    ENV['OOD_SANITIZE_BC_JOB_NAMES'] = 'NO'

    Dir.mktmpdir("dbroot") do |dir|
      dir = Pathname.new(dir)
      BatchConnect::Session.stubs(:db_root).returns(dir)

      [
        { id: "C", job_id: "RUNNING", created_at: 100, token: 'jupyter:development' },
        { id: "D", job_id: "RUNNING", created_at: 100, token: 'qgis/batch' },
      ].each do |v|
        File.open(dir.join(v[:id]), "w") do |f|
          f.write v.to_json
        end
      end

      sessions = BatchConnect::Session.all
      assert sessions.map { |session| session.send :job_name }.all? { |job_name| /[:\/]/.match?(job_name) }
    end

    ENV['OOD_SANITIZE_BC_JOB_NAMES'] = original
  end
end
