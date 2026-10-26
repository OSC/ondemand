# frozen_string_literal: true

require 'test_helper'
require 'timeout'

module BatchConnect
  # Housekeeping must exclude active writers and preserve unrelated metadata.
  class SessionStoreCleanupTest < ActiveSupport::TestCase
    setup do
      @directory = Dir.mktmpdir('session-cleanup')
      @root = Pathname.new(@directory)
      @metadata = @root.join('.session-store')
      @metadata.mkdir(0o700)
      @store = SessionStore.new(@root)
    end

    teardown do
      FileUtils.remove_entry(@directory)
    end

    def temporary_file(age: 7200)
      file = Tempfile.create('session-', @metadata)
      file.write('{"active":true}')
      file.close
      path = Pathname.new(file.path)
      timestamp = Time.now - age
      File.utime(timestamp, timestamp, path)
      path
    end

    test 'default cleanup previews old temporary files without creating a lock' do
      old = temporary_file
      fresh = temporary_file(age: 0)
      assert_equal [old], @store.cleanup_temporary_files
      assert old.file?
      assert fresh.file?
      refute @metadata.join('lock').exist?
    end

    test 'unlocked deletion requires explicit writer quiescence' do
      old = temporary_file
      assert_raises(SessionStore::LockUnavailable) { @store.cleanup_temporary_files(dry_run: false) }
      assert_raises(SessionStore::LockUnavailable) do
        @store.cleanup_temporary_files(dry_run: false, quiescent: 'true')
      end
      assert old.file?
    end

    test 'quiescent cleanup removes only old owned regular temporary files' do
      old = temporary_file
      fresh = temporary_file(age: 0)
      lock = @metadata.join('lock')
      lock.write('stable lock')
      unrelated = @metadata.join('session-unrecognized')
      unrelated.write('keep')
      outside = @root.join('record')
      outside.write('keep')
      link = @metadata.join('session-20000101-1-link')
      File.symlink(outside, link)
      nested = @metadata.join('session-20000101-1-directory')
      nested.mkdir
      hardlink = temporary_file
      File.link(hardlink, @root.join('other-link'))
      assert_equal [old], @store.cleanup_temporary_files(dry_run: false, quiescent: true)
      refute old.exist?
      [fresh, lock, unrelated, outside, link, nested, hardlink].each { |path| assert path.exist? }
      assert_equal 'keep', outside.read
    end

    test 'coordinated cleanup deletes while holding the stable store lock' do
      store = SessionStore.new(@root, locking: true)
      store.prepare!
      old = temporary_file
      metadata = @metadata
      old.define_singleton_method(:unlink) do
        File.open(metadata.join('lock'), File::RDWR) do |probe|
          raise 'cleanup did not hold the store lock' if probe.flock(File::LOCK_EX | File::LOCK_NB)
        end
        super()
      end
      Pathname.any_instance.stubs(:children).returns([old])
      assert_equal [old], store.cleanup_temporary_files(dry_run: false)
      refute old.exist?
    end

    test 'a temporary file with another owner is preserved' do
      old = temporary_file
      stat = old.lstat
      stat.stubs(:uid).returns(Process.euid + 1)
      old.stubs(:lstat).returns(stat)
      Pathname.any_instance.stubs(:children).returns([old])
      assert_empty @store.cleanup_temporary_files(dry_run: false, quiescent: true)
      assert old.file?
    end

    test 'a candidate replaced between inspection and deletion is preserved' do
      old = temporary_file
      other = temporary_file
      original = old.lstat
      replacement = other.lstat
      old.stubs(:lstat).returns(original, replacement)
      Pathname.any_instance.stubs(:children).returns([old])
      assert_empty @store.cleanup_temporary_files(dry_run: false, quiescent: true)
      assert old.file?
    end

    test 'a candidate disappearing after enumeration is harmless' do
      old = temporary_file
      old.stubs(:lstat).raises(Errno::ENOENT)
      Pathname.any_instance.stubs(:children).returns([old])
      assert_empty @store.cleanup_temporary_files(dry_run: false, quiescent: true)
    end

    test 'symlinked metadata is rejected without touching the target' do
      old = temporary_file
      target = @root.join('original-metadata')
      @metadata.rename(target)
      File.symlink(target, @metadata)
      assert_raises(ArgumentError) { @store.cleanup_temporary_files(dry_run: false, quiescent: true) }
      assert target.join(old.basename).file?
      refute target.join('lock').exist?
    end

    test 'missing metadata is a no-op without creating directories' do
      @metadata.rmdir
      assert_empty @store.cleanup_temporary_files
      refute @metadata.exist?
    end

    test 'a replaced metadata directory is rejected before deletion' do
      cleaner = SessionStoreCleanup.new(@root)
      assert cleaner.available?
      @metadata.rename(@root.join('original-metadata'))
      @metadata.mkdir(0o700)
      old = temporary_file
      assert_raises(ArgumentError) { cleaner.call(older_than: 3600, dry_run: false) }
      assert old.file?
    end

    test 'deletion errors remain visible to the operator' do
      old = temporary_file
      old.stubs(:unlink).raises(Errno::EACCES)
      Pathname.any_instance.stubs(:children).returns([old])
      assert_raises(Errno::EACCES) { @store.cleanup_temporary_files(dry_run: false, quiescent: true) }
      assert old.file?
    end

    test 'invalid ages and dry-run flags are rejected' do
      [-1, Float::INFINITY, Float::NAN].each do |age|
        assert_raises(ArgumentError) { @store.cleanup_temporary_files(older_than: age) }
      end
      assert_raises(ArgumentError) { @store.cleanup_temporary_files(dry_run: 'false') }
    end

    test 'cleanup waits until a writer has renamed its aged temporary file' do
      store = SessionStore.new(@root, locking: true)
      store.prepare!
      waiting = Queue.new
      store.define_singleton_method(:acquire_lock) do |*args, **options|
        waiting << true
        super(*args, **options)
      end
      cleaner = nil
      record = @root.join('A')
      File.open(@metadata.join('lock'), File::RDWR) do |lock|
        lock.flock(File::LOCK_EX)
        old = temporary_file
        cleaner = Thread.new { store.cleanup_temporary_files(dry_run: false) }
        Timeout.timeout(5) { waiting.pop }
        assert old.file?
        File.rename(old, record)
      end
      assert_empty Timeout.timeout(5) { cleaner.value }
      assert_equal '{"active":true}', record.read
    ensure
      cleaner&.kill
      cleaner&.join
    end
  end
end
