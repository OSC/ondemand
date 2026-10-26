# frozen_string_literal: true

require 'test_helper'

module BatchConnect
  # Lock compatibility and recovery after scheduler acceptance are separate guarantees.
  class SessionStoreFailureTest < ActiveSupport::TestCase
    setup do
      Configuration.stubs(:bc_session_store_locking?).returns(true)
      @directory = Dir.mktmpdir('session-store-failures')
      @root = Pathname.new(@directory)
      Session.stubs(:db_root).returns(@root)
      @json = { id: 'A', cluster_id: 'owens', job_id: '123', created_at: Time.now.to_i }.to_json
      @root.join('A').write(@json)
      @store = Session.store
    end

    teardown do
      FileUtils.remove_entry(@directory)
    end

    def fail_lock(error = Errno::ENOLCK, after: 0)
      lock = File.any_instance.stubs(:flock).with(File::LOCK_EX)
      after.positive? ? lock.returns(0).then.raises(error) : lock.raises(error)
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

    test 'unsupported locks allow reads without quarantining corrupt records' do
      @root.join('broken').write('{broken')
      fail_lock
      assert_equal @json, @store.read('A')
      assert_equal ['A'], @store.read_all { |json| Session.new.from_json(json) }.map(&:id)
      assert @root.join('broken').exist?
      refute @root.join('broken.bak').exist?
    end

    test 'unsupported locks reject every mutation and preserve existing records' do
      [Errno::ENOLCK, Errno::ENOSYS, Errno::EOPNOTSUPP].each do |error|
        fail_lock(error)
        assert_raises(SessionStore::LockUnavailable) { @store.prepare! }
        assert_raises(SessionStore::LockUnavailable) { @store.write('A', '{}') }
        assert_raises(SessionStore::LockUnavailable) { @store.write('B', '{}', create: true) }
        assert_raises(SessionStore::LockUnavailable) { @store.delete('A') }
        assert_equal @json, @root.join('A').read
        refute @root.join('B').exist?
      end
    end

    test 'known lock failure stops submission before contacting the scheduler' do
      session = submission
      fail_lock
      @adapter.expects(:submit).never
      @adapter.expects(:delete).never
      refute session.submit
      assert_nil session.job_id
      assert_match(/locking unavailable/, session.errors.full_messages.join)
    end

    test 'unrelated lock permission errors do not trigger read-only fallback' do
      fail_lock(Errno::EACCES)
      assert_raises(Errno::EACCES) { @store.read('A') }
      assert_raises(Errno::EACCES) { @store.read_all { |json| JSON.parse(json) } }
    end

    test 'failed persistence preserves the accepted job and reports its diagnostic ID' do
      session = submission
      @adapter.expects(:submit).returns('job-123')
      @adapter.expects(:delete).never
      File.stubs(:rename).raises(Errno::ENOSPC)
      refute session.submit
      assert_equal 'job-123', session.job_id
      assert_match(/Job job-123 was submitted/, session.errors.full_messages.join)
      assert_match(/Check this job in the scheduler before submitting again/, session.errors.full_messages.join)
      assert_match(/No space left/, session.errors.full_messages.join)
      refute @root.join('B').exist?
      assert_equal ['lock'], @root.join('.session-store').children.map(&:basename).map(&:to_s)
    end

    test 'a lock lost after preflight does not cancel the accepted job' do
      session = submission
      fail_lock(after: 1)
      @adapter.expects(:submit).returns('job-123')
      @adapter.expects(:delete).never
      refute session.submit
      assert_match(/Job job-123 was submitted/, session.errors.full_messages.join)
      assert_match(/locking unavailable/, session.errors.full_messages.join)
      refute @root.join('B').exist?
    end

    test 'failed serialization reports the accepted job without cancelling it' do
      session = submission
      @adapter.expects(:submit).returns('job-123')
      @adapter.expects(:delete).never
      session.stubs(:to_json).raises(StandardError, 'serialization failed')
      refute session.submit
      message = session.errors.full_messages.join
      assert_match(/Job job-123 was submitted/, message)
      assert_match(/serialization failed/, message)
      assert_match(/cancel it manually if needed/, message)
      refute @root.join('B').exist?
    end

    test 'read-only mode retains expired sessions and skips completion cache updates' do
      session = Session.new.from_json(@json)
      session.stubs(:completed?).returns(true)
      Session.any_instance.stubs(:completed?).returns(true)
      Configuration.stubs(:ood_bc_card_time).returns(1)
      old_time = Time.now - (3 * 86_400)
      File.utime(old_time, old_time, @root.join('A'))
      fail_lock
      assert_equal ['A'], Session.all.map(&:id)
      assert_equal false, session.update_cache_completed!
      refute session.cache_completed
      assert_nil session.completed_at
      assert_equal @json, @root.join('A').read
    end
  end
end
