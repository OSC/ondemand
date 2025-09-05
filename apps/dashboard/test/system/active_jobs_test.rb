# frozen_string_literal: true

require 'application_system_test_case'
require 'ood_core/job/adapters/slurm'

class ActiveJobsTest < ApplicationSystemTestCase
  JavascriptWaitTime = 5
  # Set alias
  NodeInfo = OodCore::Job::NodeInfo

  def setup
    # Enable routes guarded by this flag
    Configuration.stubs(:can_access_activejobs?).returns(true)

    testclusters = OodCore::Clusters.load_file('test/fixtures/config/clusters.d')
    # Use one cluster here to prevent duplicate jobs
    ActiveJobs::JobsJsonRequestHandler.any_instance.stubs(:clusters).returns([testclusters.first])
    OodCore::Cluster.any_instance.stubs(:job_config).returns({adapter:'slurm'})
    jobs = [
      OodCore::Job::Info.new(
        id:              '123',
        job_name:        'Sample1',
        accounting_id:   'account1',
        queue_name:      'normal',
        wallclock_time:  3600,
        job_owner:       "not_currentuser",
        allocated_nodes: [NodeInfo.new(name: 'node001'), NodeInfo.new(name: 'node002')],
        status:          :running
      ),
      OodCore::Job::Info.new(
        id:              '345',
        job_name:        'Sample2',
        accounting_id:   'account2',
        queue_name:      'short',
        wallclock_time:  120,
        job_owner:       "currentuser",
        allocated_nodes: [NodeInfo.new(name: 'node003')],
        status:          :queued
      ),
      OodCore::Job::Info.new(
        id:              '567',
        job_name:        'Sample3',
        accounting_id:   'account3',
        queue_name:      'short',
        wallclock_time:  120,
        job_owner:       "currentuser",
        allocated_nodes: [NodeInfo.new(name: 'node001'), NodeInfo.new(name: 'node002')],
        status:          :queued
      ),
      OodCore::Job::Info.new(
        id:              '789',
        job_name:        'Sample4',
        accounting_id:   'account4',
        queue_name:      'short',
        wallclock_time:  120,
        job_owner:       "not_currentuser",
        allocated_nodes: [NodeInfo.new(name: 'node003')],
        status:          :queued
      )
    ]

    # These stubs need to change for multi-cluster tests
    OodCore::Job::Adapter.any_instance.stubs(:supports_job_arrays?).returns(true)
    OodCore::Job::Adapter.any_instance.stubs(:info_where_owner_each).returns(jobs.select{ |job| job.job_owner == 'currentuser'})
    OodCore::Job::Adapter.any_instance.stubs(:info_all_each).returns(jobs)
  end
  

  test 'defaults to your jobs' do
    visit active_jobs_url(cluster_id:'all')
    # Finish loading
    assert_selector '#job_status_table tbody tr', minimum: 1
    # The UI should default to the "Your Jobs" filter
    assert_selector('#selected-filter-label', text: 'Your Jobs')
    # The list should have exactly two jobs in it
    box = find('#job_status_table tbody')
    rows = box.all('tr')
    assert_equal 2, rows.length 
    # Test row content (dropping the button which has no text)
    first_row_text = rows[0].all('td').map(&:text).drop(1) 
    expected_fr = [
      '345',
      'Sample2',
      'currentuser',
      'account2',
      '00:02:00',
      'short',
      'Queued',
      'Oakley',
      ''
    ]
    assert_equal 9, first_row_text.length
    assert_equal expected_fr, first_row_text

    second_row_text = rows[1].all('td').map(&:text).drop(1)
    expected_sr = [
      '567',
      'Sample3',
      'currentuser',
      'account3',
      '00:02:00',
      'short',
      'Queued',
      'Oakley',
      ''   
    ]
    assert_equal 9, second_row_text.length
    assert_equal expected_sr, second_row_text

    # check buttons
    assert_equal 2, all('#job_status_table .details-control').length
  end
end
