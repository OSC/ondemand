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
      assert_equal 100, progress.percent
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

  # FIXME: need to change this interface to something simpler
  # and then use validations to limit the scope
  test "copy updates progress once per file copied" do
    Dir.mktmpdir do |dir|
      srcdir = Rails.root.join('app')
      testdir = File.join(dir, 'app')
      destdir = File.join(dir, 'dest')
      FileUtils.mkpath destdir
      resultdir = File.join(destdir, 'app') # so will be copied to dest/app

      FileUtils.cp_r Rails.root.join('app'), testdir


      # this tests the number of calls to update_progress
      # note: progress.percent is not called because this mocks the method
      num_files = Files.new.num_files(dir, ['app'])
      TransferLocalJob.any_instance.expects(:update_progress).times(num_files)

      TransferLocalJob.perform_now('cp', dir, ['app'], destdir)

      progress = TransferLocalJob.progress.values.last
      assert_equal 0, progress.exit_status, "job exited with error #{progress.message}"
      assert_equal '', `diff -r #{srcdir} #{resultdir}`.strip
    end

    TransferLocalJob.progress = nil
  end

  ################################################################################################
  # TODO: testing mv becomes difficult without clever mocking
  # would have to mock the object returned by File.stat(path1) and File.stat(path2)
  # so that /tmp is treated as the same OR /tmp is treated as different
  #
  #
  # irb(main):001:0> File.stat '.'
  # => #<File::Stat dev=0x67, ino=97, mode=040755, nlink=173, uid=10851, gid=5515, rdev=0x0, size=36864, blksize=32768, blocks=80, atime=2020-12-29 21:34:06 -0500, mtime=2020-12-29 19:25:26 -0500, ctime=2020-12-29 19:25:26 -0500>
  # irb(main):002:0> File.stat '/tmp'
  # => #<File::Stat dev=0xfd04, ino=64, mode=041777, nlink=143, uid=0, gid=0, rdev=0x0, size=73728, blksize=4096, blocks=128, atime=2020-12-29 14:40:14 -0500, mtime=2020-12-29 21:41:32 -0500, ctime=2020-12-29 21:41:32 -0500>
  #
  # on Owens /tmp and $HOME are different devices
  # on my laptop (and many others) and a docker image /tmp and $HOME are the same device
  #
  # rsync is an alt consideration
  ################################################################################################

  # test "mv updates progress one time if on same device" do
  # end

  # test "queued job updates progress" do
  # end
end
