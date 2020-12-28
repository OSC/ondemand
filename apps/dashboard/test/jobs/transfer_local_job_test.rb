require 'test_helper'

class TransferLocalJobTest < ActiveJob::TestCase
  # include ActiveJob::TestHelper

  test "copy job copies a file" do
    Dir.mktmpdir do |dir|
      testfile = File.join(dir, 'test')
      destdir = File.join(dir, 'dest')
      File.write(testfile, 'this is a test file')
      FileUtils.mkpath destdir


      # FIXME: from, name, to does not allow for copying tot he same
      # location/same directory but with a new name
      # so we need a NEW SOLUTION...
      # or we do "to" but "with_prefix" added if from and to are the same
      # directory

      # FIXME: perform_now SKIPS the enqueue step
      # TransferLocalJob.perform_now(dir, ['test'], destdir)
      # perform_enqueued_jobs do
      #  job = TransferLocalJob.perform_later(dir, ['test'], destdir)
      #  assert job.job_id != nil
      #  assert_enqueued_jobs 1
      # end
      TransferLocalJob.perform_now('cp', dir, ['test'], destdir)
      # assert_equal 0, TransferLocalJob.progress[job.job_id]
      progress = TransferLocalJob.progress.values.last
      assert_equal 0, progress.exit_status, "job exited with error #{progress.message}"
      assert FileUtils.compare_file(testfile, File.join(destdir, 'test')), "file was not copied"
    end

    TransferLocalJob.progress = nil
  end

  test "job queues in queued state" do
    Dir.mktmpdir do |dir|
      testfile = File.join(dir, 'test')
      destdir = File.join(dir, 'dest')
      File.write(testfile, 'this is a test file')
      FileUtils.mkpath destdir

      job = TransferLocalJob.perform_later(dir, ['test'], destdir)
      assert job.job_id != nil
      assert job.progress.status.queued?
    end

    TransferLocalJob.progress = nil
  end

#  test "queued job updates progress" do
#  end

  # test "the truth" do
  #   assert true
  # end
end
