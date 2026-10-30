# frozen_string_literal: true

require 'test_helper'
require 'timeout'

module BatchConnect
  # Exercise persistence, recovery and maintenance using real files in both modes.
  class SessionStoreTest < ActiveSupport::TestCase
    setup do
      @root = Pathname.new(Dir.mktmpdir('session-store'))
      @metadata = @root.join('.session-store')
      @record = @root.join('A')
      @json = { id: 'A', cluster_id: 'owens', job_id: '123', created_at: Time.now.to_i }.to_json
      @record.write(@json)
      Session.stubs(:db_root).returns(@root)
      Session.any_instance.stubs(:completed?).returns(false)
      use_locking(enabled: false)
    end

    teardown do
      SessionStoreDiagnostics.forget(@record)
      FileUtils.remove_entry(@root)
    end

    def use_locking(enabled: true)
      Configuration.stubs(:bc_session_store_locking?).returns(enabled)
      @store = Session.store
    end

    def submission
      Session.new(id: 'B', cluster_id: 'owens', created_at: Time.now.to_i).tap do |session|
        session.stubs(:script_content).returns('script')
        session.stubs(:script_options).returns({})
        session.stubs(:sanitized_env).returns({})
        session.stubs(:job_script_content_file).returns(@root.join('script.sh'))
        session.stubs(:job_script_options_file).returns(@root.join('options.json'))
        @adapter = mock('scheduler')
        session.stubs(:adapter).returns(@adapter)
      end
    end

    def read_records
      SessionStore.new(@root).read_all { |json| JSON.parse(json) }
    end

    def temporary_file(age: 7200)
      @metadata.mkpath(mode: 0o700)
      file = Tempfile.create('session-', @metadata)
      file.write('{"active":true}')
      file.close
      File.utime(Time.now - age, Time.now - age, file.path)
      Pathname.new(file.path)
    end

    # Pause a real operation at the stable lock, then change its input on disk.
    def while_store_waits(operation)
      @store.prepare!
      waiting = Queue.new
      @store.define_singleton_method(:acquire_lock) do |*args, **options|
        waiting << true
        super(*args, **options)
      end
      worker = nil
      File.open(@metadata.join('lock'), File::RDWR) do |lock|
        lock.flock(File::LOCK_EX)
        worker = Thread.new(&operation)
        Timeout.timeout(5) { waiting.pop }
        yield
      end
      Timeout.timeout(5) { worker.value }
    ensure
      worker&.kill
      worker&.join
    end

    [false, true].each do |locking|
      test "atomic replacement, private files and failure cleanup with locking=#{locking}" do
        use_locking(enabled: locking)
        File.any_instance.expects(:flock).never unless locking
        assert_equal @json, @store.read('A')
        refute @metadata.exist? unless locking
        File.open(@record) do |reader|
          assert @store.write('A', '{}')
          assert_equal @json, reader.read
        end
        assert_equal '{}', @record.read
        assert_equal 0o600, @record.stat.mode & 0o777
        assert_equal 0o700, @metadata.stat.mode & 0o777
        assert @store.write('B', @json, create: true)
        assert_equal 0o600, @root.join('B').stat.mode & 0o777
        File.stubs(:rename).raises(Errno::ENOSPC)
        assert_raises(Errno::ENOSPC) { @store.write('A', @json) }
        assert_equal '{}', @record.read
        assert_equal(locking ? ['lock'] : [], @metadata.children.map { |path| path.basename.to_s })
      end

      test "submission, completion and repeated deletion with locking=#{locking}" do
        use_locking(enabled: locking)
        File.any_instance.expects(:flock).never unless locking
        session = submission
        @adapter.expects(:submit).returns('job-456')
        assert session.submit
        assert_equal 'job-456', JSON.parse(@root.join('B').read)['job_id']
        @metadata.join('unfinished').write('{partial')
        assert_equal ['A', 'B'], Session.all.map(&:id).sort
        session.stubs(:completed?).returns(true)
        assert session.update_cache_completed!
        assert JSON.parse(@root.join('B').read)['cache_completed']
        @adapter.expects(:delete).never
        2.times { assert session.destroy }
        refute @store.write('B', @json)
        refute @root.join('B').exist?
        session.stubs(:completed?).returns(false)
        @adapter.expects(:delete).with('job-456')
        assert session.destroy
      end
    end

    test 'completion serialization cannot recreate an already deleted record' do
      session = Session.new.from_json(@json)
      session.stubs(:completed?).returns(true)
      session.define_singleton_method(:to_json) do |*args|
        db_file.delete
        super(*args)
      end
      session.update_cache_completed!
      refute @record.exist?
    end

    test 'enumerated records may disappear and unlocked parsing must preserve replacements' do
      @root.stubs(:children).returns([@record])
      @record.stubs(:read).raises(Errno::ENOENT)
      assert_empty read_records
      @record.unstub(:read)
      assert_empty(@store.read_all do |_json|
        @record.write('{}')
        raise JSON::ParserError, 'bad JSON'
      end)
      assert_equal '{}', @record.read
      refute @root.join('A.bak').exist?
    end

    test 'coordinated quarantine tolerates disappearance and exposes permission errors' do
      use_locking
      @root.stubs(:children).returns([@record])
      @record.write('{broken')
      assert_empty Session.all
      assert_equal '{broken', @root.join('A.bak').read
      refute @record.exist?
      [Errno::ENOENT, Errno::EACCES].each do |error|
        @record.write('{broken')
        @record.stubs(:rename).raises(error)
        error == Errno::ENOENT ? assert_empty(Session.all) : assert_raises(error) { Session.all }
      end
    end

    test 'replacement holds the stable lock and a waiting writer rechecks deletion' do
      use_locking
      File.expects(:rename).with do |_source, _target|
        File.open(@metadata.join('lock'), File::RDWR) do |probe|
          refute probe.flock(File::LOCK_EX | File::LOCK_NB)
        end
        true
      end
      assert @store.write('A', '{}')
      refute while_store_waits(-> { @store.write('A', @json) }) { @record.delete }
      refute @record.exist?
    end

    [Errno::ENOLCK, Errno::ENOSYS, Errno::EOPNOTSUPP, Errno::EACCES].each do |error|
      test "lock failure #{error} preserves records and prevents scheduler side effects" do
        use_locking
        File.any_instance.stubs(:flock).with(File::LOCK_EX).raises(error)
        if error == Errno::EACCES
          assert_raises(error) { @store.read('A') }
          assert_raises(error) { @store.read_all { |json| JSON.parse(json) } }
        else
          @root.join('broken').write('{broken')
          assert_equal @json, @store.read('A')
          assert_equal ['A'], Session.all.map(&:id)
          assert @root.join('broken').exist?
          refute @root.join('broken.bak').exist?
          assert_raises(SessionStore::LockUnavailable) { @store.prepare! }
          assert_raises(SessionStore::LockUnavailable) { @store.write('A', '{}') }
          assert_raises(SessionStore::LockUnavailable) { @store.write('B', '{}', create: true) }
          assert_raises(SessionStore::LockUnavailable) { @store.delete('A') }
        end
        session = submission
        @adapter.expects(:submit).never
        @adapter.expects(:delete).never
        refute session.submit
        assert_nil session.job_id
        assert_equal @json, @record.read
        refute @root.join('B').exist?
      end
    end

    test 'unavailable locking preserves expired sessions and completion state' do
      use_locking
      Session.any_instance.stubs(:completed?).returns(true)
      Configuration.stubs(:ood_bc_card_time).returns(1)
      File.utime(Time.now - 259_200, Time.now - 259_200, @record)
      File.any_instance.stubs(:flock).raises(Errno::ENOLCK)
      assert_equal ['A'], Session.all.map(&:id)
      session = Session.new.from_json(@json)
      refute session.update_cache_completed!
      refute session.cache_completed
      assert_nil session.completed_at
      assert_equal @json, @record.read
    end

    [:rename, :serialization, :late_lock].each do |failure|
      test "accepted job survives #{failure} failure with recovery guidance" do
        use_locking
        session = submission
        File.stubs(:rename).raises(Errno::ENOSPC) if failure == :rename
        session.stubs(:to_json).raises(StandardError, 'serialization failed') if failure == :serialization
        if failure == :late_lock
          File.any_instance.stubs(:flock).with(File::LOCK_EX).returns(0).then.raises(Errno::ENOLCK)
        end
        @adapter.expects(:submit).returns('job-123')
        @adapter.expects(:delete).never
        refute session.submit
        assert_equal 'job-123', session.job_id
        message = session.errors.full_messages.join
        assert_match(/Job job-123 was submitted/, message)
        assert_match(/Check this job in the scheduler before submitting again; cancel it manually if needed/, message)
        reason = { rename: /No space left/, serialization: /serialization failed/, late_lock: /locking unavailable/ }
        assert_match(reason[failure], message)
        refute @root.join('B').exist?
        assert_equal ['lock'], @metadata.children.map(&:basename).map(&:to_s)
      end
    end

    test 'diagnostics share suppression, expiry and changed-content detection across stores' do
      @record.write('{broken')
      Process.stubs(:clock_gettime).with(Process::CLOCK_MONOTONIC).returns(100, 101, 400, 401)
      Rails.logger.expects(:error).times(3)
      3.times { assert_empty read_records }
      @record.write('{different')
      assert_empty read_records
      refute @metadata.exist?
      refute @root.join('A.bak').exist?
    end

    [:recovery, :disappearance, :eviction, :exception].each do |reset|
      test "diagnostics report again after #{reset}" do
        @record.write('{broken')
        count = reset == :eviction ? SessionStoreDiagnostics::MAX_ENTRIES : 0
        Rails.logger.expects(:error).times(count + 2)
        read_records
        @record.write('{}') if reset == :recovery
        @root.stubs(:children).returns([@record]) if reset == :disappearance
        @record.stubs(:read).raises(Errno::ENOENT) if reset == :disappearance
        read_records if [:recovery, :disappearance].include?(reset)
        count.times do |number|
          SessionStoreDiagnostics.report(@root.join("other-#{number}"), JSON::ParserError.new('bad'), '')
        end
        @record.unstub(:read)
        @record.write('{broken')
        reset == :exception ? @store.read_all { raise ArgumentError, 'different' } : read_records
      end
    end

    test 'cleanup previews and requires boolean quiescence for unlocked deletion' do
      old = temporary_file
      assert_equal [old], @store.cleanup_temporary_files
      refute @metadata.join('lock').exist?
      [nil, 'true'].each do |quiescent|
        assert_raises(SessionStore::LockUnavailable) do
          @store.cleanup_temporary_files(dry_run: false, quiescent: quiescent)
        end
      end
      assert old.file?
      [-1, Float::INFINITY, Float::NAN].each do |age|
        assert_raises(ArgumentError) { @store.cleanup_temporary_files(older_than: age) }
      end
      assert_raises(ArgumentError) { @store.cleanup_temporary_files(dry_run: 'false') }
    end

    test 'cleanup preserves fresh, unrelated, linked and nonregular entries' do
      old = temporary_file
      fresh = temporary_file(age: 0)
      lock = @metadata.join('lock')
      lock.write('stable')
      unrelated = @metadata.join('session-unrecognized')
      unrelated.write('keep')
      symlink = @metadata.join('session-20000101-1-link')
      File.symlink(@record, symlink)
      directory = @metadata.join('session-20000101-1-directory')
      directory.mkdir
      hardlink = temporary_file
      File.link(hardlink, @root.join('other-link'))
      assert_equal [old], @store.cleanup_temporary_files(dry_run: false, quiescent: true)
      refute old.exist?
      [fresh, lock, unrelated, symlink, directory, hardlink].each { |path| assert path.exist? }
      assert_equal @json, @record.read
    end

    [:owner, :replacement, :missing, :permission].each do |change|
      test "cleanup handles candidate #{change} safely" do
        old = temporary_file
        stat = old.lstat
        stat.stubs(:uid).returns(Process.euid + 1) if change == :owner
        old.stubs(:lstat).returns(stat, temporary_file.lstat) if change == :replacement
        old.stubs(:lstat).returns(stat) if change == :owner
        old.stubs(:lstat).raises(Errno::ENOENT) if change == :missing
        old.stubs(:unlink).raises(Errno::EACCES) if change == :permission
        Pathname.any_instance.stubs(:children).returns([old])
        operation = -> { @store.cleanup_temporary_files(dry_run: false, quiescent: true) }
        change == :permission ? assert_raises(Errno::EACCES, &operation) : assert_empty(operation.call)
        assert old.file?
      end
    end

    test 'cleanup rejects symlinked or replaced metadata and ignores missing metadata' do
      assert_empty @store.cleanup_temporary_files
      refute @metadata.exist?
      old = temporary_file
      cleaner = SessionStoreCleanup.new(@root)
      assert cleaner.available?
      original = @root.join('original-metadata')
      @metadata.rename(original)
      File.symlink(original, @metadata)
      assert_raises(ArgumentError) { @store.cleanup_temporary_files(dry_run: false, quiescent: true) }
      @metadata.unlink
      @metadata.mkdir(0o700)
      assert_raises(ArgumentError) { cleaner.call(older_than: 3600, dry_run: false) }
      assert original.join(old.basename).file?
    end

    test 'coordinated cleanup holds the lock and waits for an active writer to commit' do
      use_locking
      old = temporary_file
      old.expects(:unlink).with do
        File.open(@metadata.join('lock'), File::RDWR) { |probe| refute probe.flock(File::LOCK_EX | File::LOCK_NB) }
        true
      end
      Pathname.any_instance.stubs(:children).returns([old])
      assert_equal [old], @store.cleanup_temporary_files(dry_run: false)
      Pathname.any_instance.unstub(:children)
      old.unstub(:unlink)
      assert_empty(while_store_waits(-> { @store.cleanup_temporary_files(dry_run: false) }) do
        assert old.file?
        File.rename(old, @record)
      end)
      assert_equal '{"active":true}', @record.read
    end
  end
end
