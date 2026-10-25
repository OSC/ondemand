# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

module BatchConnect
  # Exercise real record files and deterministic reader/writer interleavings.
  class SessionStoreTest < ActiveSupport::TestCase
    setup do
      @directory = Dir.mktmpdir('session-store')
      @root = Pathname.new(@directory)
      Session.stubs(:db_root).returns(@root)
      Session.any_instance.stubs(:completed?).returns(false)
      @record = @root.join('A')
      @json = { id: 'A', cluster_id: 'owens', job_id: '123', created_at: Time.now.to_i }.to_json
      @record.write(@json, perm: 0o600)
    end

    teardown do
      FileUtils.remove_entry(@directory)
    end

    def completed_session
      Session.new.from_json(@json).tap { |session| session.stubs(:completed?).returns(true) }
    end

    test 'completion replaces a record without changing an existing reader snapshot' do
      File.open(@record) do |reader|
        completed_session.update_cache_completed!
        assert_equal @json, reader.read
      end
      assert JSON.parse(@record.read)['cache_completed']
      assert_equal 0o600, @record.stat.mode & 0o777
      assert_equal ['A'], Session.all.map(&:id)
    end

    test 'a completion update cannot recreate a deleted record' do
      session = completed_session
      session.define_singleton_method(:to_json) do |*args|
        db_file.delete
        super(*args)
      end
      session.update_cache_completed!
      refute @record.exist?
    end

    test 'a record removed after enumeration is skipped' do
      record = @record
      @root.stubs(:children).returns([record])
      record.define_singleton_method(:read) do
        unlink
        super()
      end
      assert_empty Session.all
    end

    test 'a corrupt record removed before quarantine is skipped' do
      @record.write('{broken')
      @root.stubs(:children).returns([@record])
      @record.define_singleton_method(:rename) do |target|
        unlink
        super(target)
      end
      assert_empty Session.all
    end

    test 'corrupt records are still quarantined' do
      @record.write('{broken')
      assert_empty Session.all
      refute @record.exist?
      assert_equal '{broken', @root.join('A.bak').read
    end

    test 'quarantine permission errors remain visible' do
      @record.write('{broken')
      @root.stubs(:children).returns([@record])
      @record.stubs(:rename).raises(Errno::EACCES)
      assert_raises(Errno::EACCES) { Session.all }
    end

    test 'failed replacement preserves the record and cleans temporary files' do
      failure = ->(_source, _target) { raise Errno::ENOSPC }
      File.stub(:rename, failure) do
        assert_raises(Errno::ENOSPC) { completed_session.update_cache_completed! }
      end
      assert_equal @json, @record.read
      assert_equal ['lock'], @root.join('.session-store').children.map(&:basename).map(&:to_s)
    end

    test 'replacement holds the stable store lock' do
      original_rename = File.method(:rename)
      called = false
      inspect_rename = lambda do |source, target|
        File.open(@root.join('.session-store/lock'), File::RDWR) do |probe|
          refute probe.flock(File::LOCK_EX | File::LOCK_NB), 'replacement must hold the store lock'
        end
        called = true
        original_rename.call(source, target)
      end
      File.stub(:rename, inspect_rename) { completed_session.update_cache_completed! }
      assert called, 'expected an atomic replacement'
    end

    test 'repeated deletion is successful without recreating the record' do
      session = completed_session
      assert session.destroy
      assert session.destroy
      refute @record.exist?
    end

    test 'temporary files are not treated as session records' do
      metadata = @root.join('.session-store')
      metadata.mkdir(0o700)
      metadata.join('unfinished').write('{partial')
      assert_equal ['A'], Session.all.map(&:id)
      assert metadata.join('unfinished').exist?
      assert_equal 0o700, metadata.stat.mode & 0o777
    end
  end
end
