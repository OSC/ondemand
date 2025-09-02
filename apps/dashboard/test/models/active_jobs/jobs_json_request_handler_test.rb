require 'test_helper'
require 'json'
require 'stringio'
require 'logger'
require Rails.application.root.join('test','models','active_jobs','active_jobs_test_helper.rb')

module ActiveJobs
  class JobsJsonRequestHandlerTest < ActiveSupport::TestCase
    include ActiveJobsTestHelper
    
    FakeStream = Struct.new(:buffer, :closed, keyword_init: true) do
      def write(str)
        self.buffer ||= ''
        self.buffer << str.to_s
      end

      def close
        self.closed = true
      end
    end

    class FakeResponse
      attr_accessor :content_type, :stream

      def initialize(stream)
        @stream = stream
      end
    end

    class FakeController
      attr_reader :logger

      def initialize
        @logger = Logger.new(StringIO.new)
      end
    end

    test 'render writes successful json for all jobs' do
      # Build fake controller/response/stream
      stream = FakeStream.new(buffer: '', closed: false)
      response = FakeResponse.new(stream)
      controller = FakeController.new

      # Build handler under test
      handler = JobsJsonRequestHandler.new(
        filter_id:  'all',
        cluster_id: 'test',
        controller: controller,
        params:     {},
        response:   response
      )

      # Prepare fake cluster and jobs
      cluster = FakeCluster.new(id: :test, title: 'Test Cluster')
      jobs = [
        OodCore::Job::Info.new(
          id:              '12345',
          job_name:        'Sample',
          accounting_id:   'account1',
          queue_name:      'normal',
          wallclock_time:  3600,
          job_owner:       "not_#{ENV['USER']}",
          allocated_nodes: [NodeInfo.new(name: 'node001'), NodeInfo.new(name: 'node002')],
          status:          :running
        ),
        OodCore::Job::Info.new(
          id:              '67890',
          job_name:        'Example',
          accounting_id:   'account2',
          queue_name:      'short',
          wallclock_time:  120,
          job_owner:       "not_#{ENV['USER']}",
          allocated_nodes: [NodeInfo.new(name: 'node003')],
          status:          :queued
        )
      ]

      # Stub internal collaborators to isolate test
      filter = Object.new
      def filter.user?
        false
      end

      def filter.apply(jobs)
        jobs
      end

      handler.define_singleton_method(:clusters) { [cluster] }
      handler.define_singleton_method(:filter) { filter }
      handler.define_singleton_method(:job_info_enumerator) { |_cluster| jobs }

      # Exercise
      handler.render

      # Verify content type set
      assert_equal Mime[:json], response.content_type

      # Verify stream closed
      assert_equal true, stream.closed

      # Verify JSON payload shape and values
      payload = JSON.parse(stream.buffer)

      assert_equal [], payload['errors']
      assert payload['data'].is_a?(Array), 'data should be an array'
      assert_equal 1, payload['data'].size, 'data should contain one slice'
      slice = payload['data'].first
      assert_equal 2, slice.size

      first = slice.first
      assert_equal 'Test Cluster',         first['cluster_title']
      assert_equal 'running',              first['status']
      assert_equal 'test',                 first['cluster']
      assert_equal '12345',                first['pbsid']
      assert_equal 'Sample',               first['jobname']
      assert_equal 'account1',             first['account']
      assert_equal 'normal',               first['queue']
      assert_equal 3600,                   first['walltime_used']
      assert_equal "not_#{ENV['USER']}",   first['username']
      assert_equal true,                   first['extended_available']
      assert_equal ['node001', 'node002'], first['nodes']
      assert_equal '',                     first['delete_path']

      second = slice.last
      assert_equal 'Test Cluster',       second['cluster_title']
      assert_equal 'queued',             second['status']
      assert_equal 'test',               second['cluster']
      assert_equal '67890',              second['pbsid']
      assert_equal 'Example',            second['jobname']
      assert_equal 'account2',           second['account']
      assert_equal 'short',              second['queue']
      assert_equal 120,                  second['walltime_used']
      assert_equal "not_#{ENV['USER']}", second['username']
      assert_equal true,                 second['extended_available']
      assert_equal ['node003'],          second['nodes']
      assert_equal '',                   second['delete_path']
    end

    test "render writes successful json for user's jobs" do
      with_modified_env(USER: 'FakeUser') do
        stream = FakeStream.new(buffer: '', closed: false)
        response = FakeResponse.new(stream)
        controller = FakeController.new

        # Build handler under test
        handler = JobsJsonRequestHandler.new(
          filter_id:  'user',
          cluster_id: 'test',
          controller: controller,
          params:     {},
          response:   response
        )

        # Prepare fake cluster and jobs
        cluster = FakeCluster.new(id: :test, title: 'Test Cluster')
        jobs = [
          OodCore::Job::Info.new(
            id:              '123',
            job_name:        'Sample',
            accounting_id:   'account1',
            queue_name:      'normal',
            wallclock_time:  3600,
            job_owner:       "not_#{ENV['USER']}",
            allocated_nodes: [NodeInfo.new(name: 'node001'), NodeInfo.new(name: 'node002')],
            status:          :running
          ),
          OodCore::Job::Info.new(
            id:              '345',
            job_name:        'Example',
            accounting_id:   'account2',
            queue_name:      'short',
            wallclock_time:  120,
            job_owner:       "#{ENV['USER']}",
            allocated_nodes: [NodeInfo.new(name: 'node003')],
            status:          :queued
          ),
          OodCore::Job::Info.new(
            id:              '567',
            job_name:        'Example',
            accounting_id:   'account2',
            queue_name:      'short',
            wallclock_time:  120,
            job_owner:       "#{ENV['USER']}",
            allocated_nodes: [NodeInfo.new(name: 'node001'), NodeInfo.new(name: 'node002')],
            status:          :queued
          ),
          OodCore::Job::Info.new(
            id:              '789',
            job_name:        'Example',
            accounting_id:   'account2',
            queue_name:      'short',
            wallclock_time:  120,
            job_owner:       "not_#{ENV['USER']}",
            allocated_nodes: [NodeInfo.new(name: 'node003')],
            status:          :queued
          )
        ]

        # Stub internal collaborators
        filter = Object.new
        def filter.user?
          true
        end

        def filter.apply(jobs)
          jobs
        end

        handler.define_singleton_method(:clusters) { [cluster] }
        handler.define_singleton_method(:filter) { filter }
        # Simulate ood_core operation
        handler.define_singleton_method(:job_info_enumerator) do |_cluster|
          jobs.select do |job|
            job.job_owner == ENV['USER']
          end
        end

        # Exercise
        handler.render

        # Verify content type set
        assert_equal Mime[:json], response.content_type
        # Verify stream closed
        assert_equal true, stream.closed
        # Verify JSON payload shape and values
        payload = JSON.parse(stream.buffer)

        assert_equal [], payload['errors']
        assert payload['data'].is_a?(Array), 'data should be an array'
        assert_equal 1, payload['data'].size, 'data should contain one slice'
        slice = payload['data'].first
        assert_equal 2, slice.size

        first = slice.first
        assert_equal 'Test Cluster',                       first['cluster_title']
        assert_equal 'queued',                             first['status']
        assert_equal 'test',                               first['cluster']
        assert_equal '345',                                first['pbsid']
        assert_equal 'Example',                            first['jobname']
        assert_equal 'account2',                           first['account']
        assert_equal 'short',                              first['queue']
        assert_equal 120,                                  first['walltime_used']
        assert_equal 'FakeUser',                           first['username']
        assert_equal true,                                 first['extended_available']
        assert_equal ['node003'],                          first['nodes']
        assert_equal '/activejobs?cluster=test&pbsid=345', first['delete_path']

        second = slice.second
        assert_equal 'Test Cluster',                       second['cluster_title']
        assert_equal 'queued',                             second['status']
        assert_equal 'test',                               second['cluster']
        assert_equal '567',                                second['pbsid']
        assert_equal 'Example',                            second['jobname']
        assert_equal 'account2',                           second['account']
        assert_equal 'short',                              second['queue']
        assert_equal 120,                                  second['walltime_used']
        assert_equal 'FakeUser',                           second['username']
        assert_equal true,                                 second['extended_available']
        assert_equal ['node001', 'node002'],               second['nodes']
        assert_equal '/activejobs?cluster=test&pbsid=567', second['delete_path']
      end
    end

    test 'does not error when no jobs' do
      stream = FakeStream.new(buffer: '', closed: false)
      response = FakeResponse.new(stream)
      controller = FakeController.new

      # Build handler under test
      handler = JobsJsonRequestHandler.new(
        filter_id:  'all',
        cluster_id: 'test',
        controller: controller,
        params:     {},
        response:   response
      )

      cluster = FakeCluster.new(id: :test, title: 'Test Cluster')
      jobs = Array.new

      filter = Object.new
      def filter.user?
        false
      end

      def filter.apply(jobs)
        jobs
      end

      handler.define_singleton_method(:clusters) { [cluster] }
      handler.define_singleton_method(:filter) { filter }
      handler.define_singleton_method(:job_info_enumerator) { |_cluster| jobs }

      handler.render

      # Verify content type set
      assert_equal Mime[:json], response.content_type

      # Verify stream closed
      assert_equal true, stream.closed

      # Verify JSON payload shape and values
      payload = JSON.parse(stream.buffer)

      assert_equal [], payload['errors']
      assert_equal [], payload['data']
    end
  end
end
