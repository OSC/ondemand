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
      transfer = PosixTransfer.build(action: 'cp', files: {testfile => destfile})
      transfer.perform

      assert_equal 0, transfer.exit_status, "job exited with error #{transfer.errors.full_messages}"
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
  #     transfer = PosixTransfer.build(action: 'cp', files: {testfile => destfile})
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

        transfer = PosixTransfer.build(action: 'cp', files: {testfile => destfile})
        transfer.perform

        assert_equal 1, transfer.exit_status, "job exited with error #{transfer.errors.full_messages}"
        refute transfer.success?
        assert_equal 1, transfer.errors.count

        err_message = transfer.errors.full_messages[0]

        assert_equal("Copy Permission denied @ rb_dir_s_empty_p - #{dir}/foo/bar", err_message)
      ensure
        FileUtils.chmod 0755, File.join(dir, 'foo/bar')

        # HACK:
        # even after changing the directory permissions back, Dir.mktmpdir block
        # is still not removing the directory
        #
        #     Errno::ENOTEMPTY: Directory not empty @ dir_s_rmdir - /tmp/d20210414-82646-osj7pv
        #
        # per definition, the block form is supposed to remove the directory
        # but since it doesn't here we do it
        FileUtils.rm_rf File.join(dir, 'foo')
        FileUtils.rm_rf File.join(dir, 'dest')
      end
    end
  end

  test "job queues in queued state" do
    Dir.mktmpdir do |dir|
      testfile = File.join(dir, 'test')
      destfile = File.join(dir, 'dest', 'test')
      File.write(testfile, 'this is a test file')
      FileUtils.mkpath File.dirname(destfile)

      transfer = PosixTransfer.build(action: 'cp', files: {testfile => destfile})
      transfer.save
      job = TransferLocalJob.perform_later(transfer)
      assert job.job_id != nil
      assert transfer.status.queued?
    end

    Transfer.transfers.clear
  end

  # FIXME: need to change this interface to something simpler
  # and then use validations to limit the scope
  test "copy updates progress once per item copied" do
    Dir.mktmpdir do |dir|
      src_paths = Rails.root.join('app').children
      destdir = File.join(dir, 'dest').tap { |path| FileUtils.mkpath(path.to_s) }
      dest_paths = src_paths.map { |path| "#{dir}/dest/#{File.basename(path)}" }
      input = src_paths.zip(dest_paths).to_h


      # this tests the number of calls to update_progress
      # note: progress.percent is not called because this mocks the method
      num_paths = src_paths.map do |path|
        Dir["#{path}/**/*"].length
      end.sum
      transfer = PosixTransfer.build(action: 'cp', files: input)
      assert_equal(num_paths, transfer.steps)
      # FIXME: This is a littly buggy - it's updating percent for all the parent
      # directories + 1 more time.
      transfer.expects(:percent=).times(num_paths..num_paths + src_paths.length + 1)

      transfer.perform

      assert_equal 0, transfer.exit_status, "job exited with error #{transfer.stderr}"
      assert_equal '', `diff -r #{destdir} #{Rails.root.join('app')}`.strip
    end
  end

  # lots of things are covered in test/system/files_test.rb
  # As system tests, they rely on the UI which doesn't show things
  # outside the allowlist. So these tests are here just in case someone
  # is able to bypass the UI (using javascript/curl or similar)
  test 'will not copy symlinks that point outside of allowlist' do
    Dir.mktmpdir do |dir|
      with_modified_env({ OOD_ALLOWLIST_PATH: dir }) do
        FileUtils.mkdir_p(["#{dir}/src", "#{dir}/dest"])
        `cd #{dir}/src; ln -s /etc`
        input = { "#{dir}/src/etc/passwd" => "#{dir}/dest" }

        transfer = PosixTransfer.build(action: 'cp', files: input)
        transfer.perform
        sleep 3 # give it a second to copy

        dest = Pathname.new("#{dir}/dest")
        assert(dest.empty?, "#{dest} is not empty, contains #{dest.children}")
        assert_equal(1, transfer.exit_status, "job exited with error #{transfer.errors.full_messages}")
        refute(transfer.success?)
        assert_equal(1, transfer.errors.count)

        actual = transfer.errors.full_messages[0]
        expected = 'Copy /etc/passwd does not have an ancestor directory specified in ALLOWLIST_PATH'

        assert_equal(expected, actual)
      end
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
