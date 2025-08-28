# frozen_string_literal: true

require 'test_helper'
require Rails.application.root.join('test','models','active_jobs','active_jobs_test_helper.rb')

module ActiveJobs
  class JobstatusdataTest < ActiveSupport::TestCase
    include ActiveJobsTestHelper

    # Dummy object for OodCore::Job::Info
    FakeJobInfo = Struct.new(
      :id,
      :status,
      :allocated_nodes,
      :submit_host,
      :job_name,
      :job_owner,
      :accounting_id,
      :procs,
      :queue_name,
      :wallclock_time,
      :wallclock_limit,
      :cpu_time,
      :submission_time,
      :dispatch_time,
      :native,
      :gpus,
      :tasks,
      keyword_init: true
    )

    # Dummy class for OodCore::Clusters
    class FakeClusters
      include Enumerable

      def initialize(clusters)
        @clusters = clusters
      end

      def [](id)
        @clusters.detect { |cluster| cluster == id }
      end

      def each(&block)
        @clusters.each(&block)
      end
    end
    
    # Redefine OODClusters constant to use dummy clusters
    Object.send(:remove_const, :OODClusters) 

    ActiveJobs::Jobstatusdata::OODClusters = FakeClusters.new([
      FakeCluster.new(id: :test, title: 'Test Cluster'),
      FakeCluster.new(id: :sample, title: 'Sample Cluster')
    ])

    # Alias constant for easy reference inside tests
    OODClusters = ActiveJobs::Jobstatusdata::OODClusters

    test 'default no extensions' do 
      info = FakeJobInfo.new(
        id:             12,
        job_name:       'test_job',
        job_owner:      'Fake User',
        accounting_id:  123,
        status:         Status.new(:running),
        wallclock_time: 120,
        queue_name:     'regular'
      )
      
      data = Jobstatusdata.new(info)
      
      # Test supplied data
      assert_equal 12,          data.pbsid
      assert_equal 'test_job',  data.jobname
      assert_equal 'Fake User', data.username
      assert_equal 123,         data.account
      assert_equal 'running',   data.status
      assert_equal '00:02:00',  data.walltime_used
      assert_equal 'regular',   data.queue

      # Test defaults
      assert data.extended_available
      assert_equal OODClusters.first.id.to_s,        data.cluster
      assert_equal OODClusters.first.metadata.title, data.cluster_title
    end
  end
end
