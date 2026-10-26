# frozen_string_literal: true

require 'test_helper'

module BatchConnect
  # Default persistence must not depend on home-filesystem advisory locking.
  class SessionStoreAtomicTest < ActiveSupport::TestCase
    setup do
      @directory = Dir.mktmpdir('session-store-atomic')
      @root = Pathname.new(@directory)
      @json = { id: 'A', cluster_id: 'owens', job_id: '123', created_at: Time.now.to_i }.to_json
      @root.join('A').write(@json)
      Configuration.stubs(:bc_session_store_locking?).returns(false)
      Session.stubs(:db_root).returns(@root)
      Session.any_instance.stubs(:completed?).returns(false)
      @store = SessionStore.new(@root)
    end

    teardown do
      FileUtils.remove_entry(@directory)
    end

    test 'default reads do not acquire locks or create metadata' do
      File.any_instance.expects(:flock).never
      assert_equal @json, @store.read('A')
      assert_equal ['A'], Session.all.map(&:id)
      refute @root.join('.session-store').exist?
    end

    test 'default replacement preserves reader snapshots without locking' do
      File.any_instance.expects(:flock).never
      File.open(@root.join('A')) do |reader|
        assert @store.write('A', '{"replaced":true}')
        assert_equal @json, reader.read
      end
      assert_equal '{"replaced":true}', @root.join('A').read
      assert_equal 0o600, @root.join('A').stat.mode & 0o777
      assert_equal 0o700, @root.join('.session-store').stat.mode & 0o777
      assert_empty @root.join('.session-store').children
    end

    test 'default corrupt-record reads do not quarantine a replacement' do
      record = @root.join('A')
      record.write('{broken')
      records = @store.read_all do |_json|
        record.write(@json)
        raise JSON::ParserError, 'bad JSON'
      end
      assert_empty records
      assert_equal @json, record.read
      refute @root.join('A.bak').exist?
    end

    test 'default deletion is idempotent and does not recreate absent records' do
      File.any_instance.expects(:flock).never
      assert @store.delete('A')
      assert @store.delete('A')
      refute @store.write('A', @json)
      refute @root.join('A').exist?
    end

    test 'default persistence leaves the old record intact on replacement failure' do
      File.stubs(:rename).raises(Errno::ENOSPC)
      assert_raises(Errno::ENOSPC) { @store.write('A', '{}') }
      assert_equal @json, @root.join('A').read
      assert_empty @root.join('.session-store').children
    end

    test 'default submission and deletion do not require flock' do
      File.any_instance.expects(:flock).never
      session = Session.new(id: 'B', cluster_id: 'owens', created_at: Time.now.to_i)
      session.stubs(:script_content).returns('script')
      session.stubs(:script_options).returns({})
      session.stubs(:sanitized_env).returns({})
      session.stubs(:job_script_content_file).returns(@root.join('script.sh'))
      session.stubs(:job_script_options_file).returns(@root.join('options.json'))
      adapter = mock('scheduler')
      session.stubs(:adapter).returns(adapter)
      adapter.expects(:submit).returns('job-456')
      assert session.submit
      assert_equal 'job-456', JSON.parse(@root.join('B').read)['job_id']

      adapter.expects(:delete).with('job-456').once
      assert session.destroy
      refute @root.join('B').exist?
    end
  end
end
