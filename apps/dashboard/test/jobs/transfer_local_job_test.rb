require 'test_helper'

class TransferLocalJobTest < ActiveJob::TestCase
  # include ActiveJob::TestHelper

  test "copy job copies a file" do
    Dir.mktmpdir do |dir|
      testfile = File.join(dir, 'test')
      destfile = File.join(dir, 'dest', 'test')
      File.write(testfile, 'this is a test file')
      FileUtils.mkpath File.dirname(destfile)

      # FIXME: from, name, to does not allow for copying tot he same
      # location/same directory but with a new name
      # so we need a NEW SOLUTION...
      # or we do "to" but "with_prefix" added if from and to are the same
      # directory
      # end
      transfer = Transfer.new(action: 'cp', files: {testfile => destfile})
      transfer.perform

      assert_equal 0, transfer.exit_status, "job exited with error #{transfer.stderr}"
      assert FileUtils.compare_file(testfile, destfile), "file was not copied"
      assert_equal 100, transfer.percent
    end
  end

  # TODO:
  # server side needs to support copying into the SAME directory with a different name
  # test "copy supports copying to same directory with different name" do
  #   Dir.mktmpdir do |dir|
  #
  #     Dir.chdir(dir) do
  #       FileUtils.mkdir_p 'foo/bar'
  #       FileUtils.touch ['foo/foo.txt', 'foo/bar/bar.txt']
  #     end
  #
  #     testfile = File.join(dir, 'foo')
  #     destfile = File.join(dir, 'dest')
  #
  #     transfer = Transfer.new(action: 'cp', files: {testfile => destfile})
  #     transfer.perform
  #
  #     assert transfer.stderr.empty?, "copy should have resulted in no errors but had stderr: #{transfer.stderr}"
  #     assert_equal 0, transfer.exit_status, "job exited with error #{transfer.stderr}"
  #   end
  # end

  test "copy job reports errors during copy" do
    Dir.mktmpdir do |dir|
      begin
        Dir.chdir(dir) do
          FileUtils.mkdir_p ['foo/bar', 'dest']
          FileUtils.touch ['foo/foo.txt', 'foo/bar/bar.txt']
          FileUtils.chmod 0000, 'foo/bar'
        end

        testfile = File.join(dir, 'foo')
        destfile = File.join(dir, 'dest/foo')

        transfer = Transfer.new(action: 'cp', files: {testfile => destfile})
        transfer.perform

        puts transfer.stderr

        assert transfer.stderr.present?, 'copy should have preserved stderr of job'
        assert transfer.stderr.include?('foo/bar')
        assert_equal 1, transfer.exit_status.exitstatus, "job exited with error #{transfer.stderr}"
        refute transfer.exit_status.success?
        assert_equal 1, transfer.errors.count

        assert File.file?(File.join(dir, 'dest/foo/foo.txt')), 'copy should have done a partial copy foo/foo.txt but skipped bar'

      ensure
        FileUtils.chmod 0755, File.join(dir, 'foo/bar')
      end
    end
  end

  test "job queues in queued state" do
    Dir.mktmpdir do |dir|
      testfile = File.join(dir, 'test')
      destfile = File.join(dir, 'dest', 'test')
      File.write(testfile, 'this is a test file')
      FileUtils.mkpath File.dirname(destfile)

      transfer = Transfer.new(action: 'cp', files: {testfile => destfile})
      transfer.save
      job = TransferLocalJob.perform_later(transfer)
      assert job.job_id != nil
      assert transfer.status.queued?
    end

    Transfer.transfers.clear
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
      transfer = Transfer.new(action: 'cp', files: {testdir => File.join(destdir, 'app')})
      transfer.expects(:percent=).times(num_files)

      transfer.perform

      assert_equal 0, transfer.exit_status, "job exited with error #{transfer.stderr}"
      assert_equal '', `diff -r #{srcdir} #{resultdir}`.strip
    end
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
