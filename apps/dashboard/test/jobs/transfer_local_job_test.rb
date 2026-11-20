require 'test_helper'

class TransferLocalJobTest < ActiveJob::TestCase
  # Override test.rb's AsyncAdapter so enqueueing cannot start a copy.
  def queue_adapter_for_test
    ActiveJob::QueueAdapters::TestAdapter.new
  end

  test "copy job copies a file" do
    Dir.mktmpdir do |dir|
      testfile = File.join(dir, 'test')
      destfile = File.join(dir, 'dest', 'test')
      File.write(testfile, 'this is a test file')

      # FIXME: from, name, to does not allow for copying tot he same
      # location/same directory but with a new name
      # so we need a NEW SOLUTION...
      # or we do "to" but "with_prefix" added if from and to are the same
      # directory
      # end
      transfer = PosixTransfer.build(action: 'cp', files: {testfile => destfile})
      transfer.expects(:percent=).with(100).once
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

        assert_match(/Permission denied.*#{Regexp.escape(File.join(dir, "foo/bar"))}/, err_message)
        refute File.exist?(File.join(dir, 'dest/foo/bar')), 'an unreadable directory should not be created'
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
      assert_enqueued_with(job: TransferLocalJob, args: [transfer]) do
        assert_not_nil TransferLocalJob.perform_later(transfer).job_id
      end
      assert transfer.status.queued?
    end
  ensure
    Transfer.transfers.clear
  end


  test "copy progress ticks once per entry and finishes at 100" do
    Dir.mktmpdir do |dir|
      src = Pathname.new(dir).join('src[1]')
      src.join('empty').mkpath
      src.join('nested', 'deep').mkpath
      src.join('nested', 'deep', 'file').write('file')
      src.join('one').write('one')
      src.join('.hidden').write('hidden')
      pipe = src.join('pipe')
      File.mkfifo(pipe)
      dest = Pathname.new(dir).join('new', 'dest')
      empty = Pathname.new(dir).join('empty').tap(&:mkdir)
      link = Pathname.new(dir).join('link')
      link.make_symlink(src)
      empty_copy = dest.parent.join('empty')
      link_copy = dest.parent.join('link')

      transfer = PosixTransfer.build(action: 'cp', files: {
        src.to_s => dest.to_s, empty.to_s => empty_copy.to_s, link.to_s => link_copy.to_s,
        pipe.to_s => dest.parent.join('pipe').to_s
      })
      seen = []
      transfer.define_singleton_method(:percent=) { |pct| seen << pct }
      transfer.perform

      assert transfer.success?, transfer.errors.full_messages.inspect
      assert_equal 9, transfer.steps
      assert_equal [11, 22, 33, 44, 55, 66, 77, 88, 100], seen
      assert system('diff', '-r', '-x', pipe.basename.to_s, src.to_s, dest.to_s)
      assert_predicate empty_copy, :empty?
      assert_equal src, link_copy.readlink
      refute_predicate dest.join('pipe'), :exist?
      refute_predicate dest.parent.join('pipe'), :exist?
    end
  end

  test "copy keeps directory permissions like cp -r" do
    old_umask = File.umask(0o022)
    Dir.mktmpdir do |dir|
      src = Pathname.new(dir).join('src')
      src.join('sub', 'empty').mkpath
      src.join('readonly').mkpath
      src.join('notes.txt').write('notes')
      src.join('readonly', 'file').write('file')
      src.join('notes.txt').chmod(0o644)
      src.join('sub', 'empty').chmod(0o700)
      src.join('sub').chmod(0o1750)
      src.join('readonly').chmod(0o555)
      src.chmod(0o700)
      dest = Pathname.new(dir).join('dest')

      begin
        transfer = PosixTransfer.build(action: 'cp', files: { src.to_s => dest.to_s })
        transfer.perform

        assert transfer.success?, transfer.errors.full_messages.inspect
        mode = ->(path) { format('%o', path.stat.mode & 0o7777) }

        assert_equal '700', mode.call(dest), 'a private directory became readable by others'
        assert_equal '1750', mode.call(dest.join('sub'))
        assert_equal '700', mode.call(dest.join('sub', 'empty'))
        assert_equal '555', mode.call(dest.join('readonly'))
        assert_equal '644', mode.call(dest.join('notes.txt'))
        assert_equal 'file', dest.join('readonly', 'file').read
      ensure
        [src, dest].each { |d| d.join('readonly').chmod(0o755) if d.join('readonly').exist? }
      end
    end
  ensure
    File.umask(old_umask)
  end

  test "copy keeps a partial directory private when a child copy fails" do
    old_umask = File.umask(0o022)
    Dir.mktmpdir do |dir|
      src = Pathname.new(dir).join('src')
      src.mkdir(0o755)
      src.join('notes').write('notes')
      dest = Pathname.new(dir).join('dest')

      transfer = PosixTransfer.build(action: 'cp', files: { src.to_s => dest.to_s })
      transfer.define_singleton_method(:cp_single) do |source, target|
        super(source, target)
        raise Errno::EIO, target.to_s
      end
      transfer.perform

      refute transfer.success?
      assert_equal 'notes', dest.join('notes').read
      assert_equal 0o700, dest.stat.mode & 0o777
    end
  ensure
    File.umask(old_umask)
  end

  test "copy reports an error when it cannot stat a listed child" do
    skip 'requires an unprivileged user' if Process.euid.zero?

    Dir.mktmpdir do |dir|
      src = Pathname.new(dir).join('src').tap(&:mkdir)
      src.join('notes').write('notes')
      src.chmod(0o400)
      dest = Pathname.new(dir).join('dest')

      transfer = PosixTransfer.build(action: 'cp', files: { src.to_s => dest.to_s })
      transfer.perform

      refute transfer.success?
      assert_match(/Permission denied.*notes/, transfer.errors[:copy].first)
    ensure
      src.chmod(0o700)
      dest.chmod(0o700) if dest.exist?
    end
  end

  test "copy respects default ACLs on the destination" do
    Dir.mktmpdir do |dir|
      root = Pathname.new(dir)
      src = root.join('src')
      child = src.join('child')
      child.mkpath
      empty = src.join('empty')
      empty.mkdir(0o755)
      empty.chmod(0o755)
      src.chmod(0o755)
      child.chmod(0o755)
      child.join('file').write('data')
      project = root.join('project').tap(&:mkdir)

      acl_set = system('setfacl', '-m', 'd:u::rwx,d:g::---,d:o::---', project.to_s, out: File::NULL)
      if ENV['OOD_TEST_REQUIRE_ACL'] == '1'
        assert acl_set, 'setfacl must be able to set a default ACL'
      end
      skip 'default ACLs require setfacl and filesystem support' unless acl_set

      dest = project.join('copy')
      transfer = PosixTransfer.build(action: 'cp', files: { src.to_s => dest.to_s })
      transfer.perform

      assert transfer.success?, transfer.errors.full_messages.inspect
      assert_equal 0o700, dest.stat.mode & 0o777
      assert_equal 0o700, dest.join('child').stat.mode & 0o777
      assert_equal 0o700, dest.join('empty').stat.mode & 0o777
      assert_predicate dest.join('empty'), :empty?
      assert_equal 'data', dest.join('child', 'file').read
    end
  end

  test "copy rejects destinations inside the source directory" do
    Dir.mktmpdir do |dir|
      root = Pathname.new(dir)
      src = root.join('src')
      nested = src.join('nested').tap(&:mkpath)
      link = root.join('link')
      link.make_symlink(nested)

      [nested, link].each do |parent|
        missing_parent = parent.join('missing')
        dest = missing_parent.join('copy')
        transfer = PosixTransfer.build(action: 'cp', files: { src.to_s => dest.to_s })
        transfer.perform

        refute transfer.success?
        assert_match(/cannot copy a directory into itself/, transfer.errors.full_messages.first)
        refute_predicate missing_parent, :exist?
      end
    end
  end

  test "copy leaves a directory created after validation alone" do
    Dir.mktmpdir do |dir|
      src = Pathname.new(dir).join('src')
      src.mkdir(0o700)
      src.join('notes').write('notes')
      dest = Pathname.new(dir).join('dest')

      transfer = PosixTransfer.build(action: 'cp', files: { src.to_s => dest.to_s })
      assert transfer.valid?
      dest.mkdir
      dest.chmod(0o755)
      transfer.perform

      refute transfer.success?
      assert_predicate dest, :empty?
      assert_equal 0o755, dest.stat.mode & 0o777
    end
  end

  test "file copy leaves a file created after validation alone" do
    Dir.mktmpdir do |dir|
      src = Pathname.new(dir).join('source')
      src.write('source data')
      dest = Pathname.new(dir).join('target')
      transfer = PosixTransfer.build(action: 'cp', files: { src.to_s => dest.to_s })
      assert transfer.valid?

      dest.write('existing data')
      transfer.perform

      refute transfer.success?
      assert_equal 'existing data', dest.read
    end
  end

  test "file and symlink copies leave a directory created after validation alone" do
    Dir.mktmpdir do |dir|
      root = Pathname.new(dir)
      src = root.join('source').tap { |path| path.write('source data') }
      link = root.join('link').tap { |path| path.make_symlink(src) }

      [src, link].each do |source|
        dest = root.join("#{source.basename}-target")
        transfer = PosixTransfer.build(action: 'cp', files: { source.to_s => dest.to_s })
        assert transfer.valid?

        dest.mkdir
        existing = dest.join(src.basename).tap { |path| path.write('existing data') }
        transfer.perform

        refute transfer.success?
        assert_equal [existing], dest.children
        assert_equal 'existing data', existing.read
      end
    end
  end

  test "copy into a setgid directory keeps the inherited setgid bit" do
    skip 'setgid inheritance on directories is Linux behavior' unless RUBY_PLATFORM.include?('linux')

    old_umask = File.umask(0o022)
    Dir.mktmpdir do |dir|
      src = Pathname.new(dir).join('src')
      src.join('inner').mkpath
      src.join('inner', 'file').write('file')
      src.join('inner').chmod(0o750)
      src.chmod(0o700)
      project = Pathname.new(dir).join('project')
      project.mkpath
      project.chmod(0o2775)
      dest = project.join('copy')

      transfer = PosixTransfer.build(action: 'cp', files: { src.to_s => dest.to_s })
      transfer.perform

      assert transfer.success?, transfer.errors.full_messages.inspect
      assert_equal '2700', format('%o', dest.stat.mode & 0o7777)
      assert_equal '2750', format('%o', dest.join('inner').stat.mode & 0o7777)
    end
  ensure
    File.umask(old_umask) if old_umask
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
