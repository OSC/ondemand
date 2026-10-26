# frozen_string_literal: true

require 'test_helper'

module BatchConnect
  # Repeated listings share diagnostic limits without moving unlocked records.
  class SessionStoreDiagnosticsTest < ActiveSupport::TestCase
    setup do
      @directory = Dir.mktmpdir('session-diagnostics')
      @root = Pathname.new(@directory)
      @record = @root.join('A')
      @record.write('{broken')
    end

    teardown do
      SessionStoreDiagnostics.forget(@record)
      FileUtils.remove_entry(@directory)
    end

    def read_records
      SessionStore.new(@root).read_all { |json| JSON.parse(json) }
    end

    test 'fresh store instances suppress unchanged parse errors without quarantine' do
      Rails.logger.expects(:error).once
      3.times { assert_empty read_records }
      assert_equal '{broken', @record.read
      refute @root.join('A.bak').exist?
      refute @root.join('.session-store').exist?
    end

    test 'a different corrupt replacement is reported immediately' do
      Rails.logger.expects(:error).twice
      read_records
      @record.write('{different')
      read_records
    end

    test 'successful recovery permits a later failure to be reported' do
      Rails.logger.expects(:error).twice
      read_records
      @record.write('{}')
      assert_equal [{}], read_records
      @record.write('{broken')
      read_records
    end

    test 'a disappeared record clears its diagnostic history' do
      Rails.logger.expects(:error).twice
      read_records
      record = @record
      @root.stubs(:children).returns([record])
      record.stubs(:read).raises(Errno::ENOENT)
      assert_empty read_records
      record.unstub(:read)
      read_records
    end

    test 'unchanged errors are reported again after the suppression interval' do
      Process.stubs(:clock_gettime).with(Process::CLOCK_MONOTONIC).returns(100, 101, 400)
      Rails.logger.expects(:error).twice
      3.times { read_records }
    end

    test 'diagnostic history is bounded across record paths' do
      count = SessionStoreDiagnostics::MAX_ENTRIES
      Rails.logger.expects(:error).times(count + 2)
      error = JSON::ParserError.new('bad JSON')
      SessionStoreDiagnostics.report(@record, error, '{broken')
      count.times do |number|
        SessionStoreDiagnostics.report(@root.join("other-#{number}"), error, '{broken')
      end
      SessionStoreDiagnostics.report(@record, error, '{broken')
    end
  end
end
