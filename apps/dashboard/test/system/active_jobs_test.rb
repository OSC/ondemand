# frozen_string_literal: true

require 'application_system_test_case'
require 'ood_core/job/adapters/slurm'

class ActiveJobsTest < ApplicationSystemTestCase
  JavascriptWaitTime = 5
  # Set alias
  NodeInfo = OodCore::Job::NodeInfo

  DetailsHeaders = [
    'Cluster',
    'Job Id',
    'Array Job Id',
    'Array Task Id',
    'Job Name',
    'User',
    'Account',
    'Partition',
    'State',
    'Reason',
    'Total Nodes',
    'Total CPUs',
    'Time Limit',
    'Time Used',
    'Start Time',
    'End Time',
    'Memory',
    'GRES'
  ]

  # Define selector statements
  MainbodySelect = '#job_status_table tbody'
  ButtonSelect = "#{MainbodySelect} .details-control"
  DetailsSelect = "#{MainbodySelect} div.panel.panel-default"
  
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
        status:          :queued,
        native: {
          array_job_id:  '12345',
          array_task_id: '1',
          state:         'running',
          reason:        'None',
          nodes:         2,
          cpus:          64,
          time_limit:    '01:00:00',
          start_time:    '2025-08-28T14:00:00',
          end_time:      '2025-08-28T15:00:00',
          min_memory:    '128GB',
          gres:          'gres:gpu:2',
          work_dir:      '/home/user/slurm_job'
        }
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
    # Stub the info method one by one (this one had to be slurm specific for some reason)
    jobs.each do |job|
      OodCore::Job::Adapters::Slurm.any_instance.stubs(:info).with(job.id).returns(job)
    end
    # Allow OODClusters to respond to Oakley
    OODClusters.stubs(:[]).with(:oakley).returns(testclusters.first)
    OODClusters.stubs(:[]).with('oakley').returns(testclusters.first)
    OODClusters.stubs(:[]).with('all').returns(testclusters)
  end

  test 'defaults to your jobs' do
    visit active_jobs_url
    
    # Finish loading
    assert_selector("#{MainbodySelect} tr", minimum: 2)
    # The UI should default to the "Your Jobs" filter
    assert_selector('#selected-filter-label', text: 'Your Jobs')
    # The list should have exactly two jobs in it
    box = find(MainbodySelect)
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

    # Check buttons
    assert_equal 2, all(ButtonSelect).length

    # Click buttons
    all(ButtonSelect).map(&:click)
    

    # Wait for load
    assert_selector("#{DetailsSelect} tr")
    
    # Confirm details
    card_header_items = all("#{DetailsSelect} div.card-header span")
    exp_header_data = ['Queued', 'Sample2', '345']
    assert_equal exp_header_data, card_header_items.map(&:text)

    headers = all("#{DetailsSelect} div.card-body td.col-xs-2")
    details = all("#{DetailsSelect} div.card-body td.col-xs-10")

    exp_details = [
      'Oakley',
      '345',
      '12345',
      '1',
      'Sample2',
      'currentuser',
      'account2',
      'short',
      'running',
      'None',
      '2',
      '64',
      '01:00:00',
      '00:02:00',
      '2025-08-28 14:00:00',
      '2025-08-28 15:00:00',
      '128GB',
      'gpu:2'
    ]

    assert_equal DetailsHeaders, headers.map(&:text)
    assert_equal exp_details, details.map(&:text)

    assert_selector('div.alert-warning')
  end


  test 'refreshes when filter is switched' do
    visit active_jobs_url#(cluster_id: 'all')

    # Finish loading
    assert_selector("#{MainbodySelect} tr", minimum: 2)

    # Open the filters dropdown (first group is filters)
    first('div.btn-group').find('button.dropdown-toggle').click
    click_on 'All Jobs'

    # The page should reload with the new filter in the query string
    assert_match(/jobfilter=all/, page.current_url)
    assert_selector('#selected-filter-label', text: 'All Jobs')

    # Check number of rows
    assert_selector("#{MainbodySelect} tr", minimum: 4)

    # Check non-user job info
    assert_text('Sample1')
    assert_text('Sample4')
    assert_text('account1')
    assert_text('account4')
    assert_text('not_currentuser')

    # Switch back to your jobs
    first('div.btn-group').find('button.dropdown-toggle').click
    click_on 'Your Jobs'

    # Check url
    assert_match(/jobfilter=user/, page.current_url)
    assert_selector('#selected-filter-label', text: 'Your Jobs')

    # Check non-user info is not displayed
    refute_text('Sample1')
    refute_text('Sample4')
    refute_text('account1')
    refute_text('account4')
    refute_text('not_currentuser')
  end

  test 'many jobs paginate' do 
    # duplicate jobs and fix id overlap
    current_jobs = OodCore::Job::Adapter.new.info_all_each
    id = 0
    new_jobs = (current_jobs*100).map do |job|
      id += 1
      OodCore::Job::Info.new(**job.to_h.merge({id: id.to_s}))
    end
    OodCore::Job::Adapter.any_instance.stubs(:info_all_each).returns(new_jobs)

    visit active_jobs_url(jobfilter:'all')

    # Finish loading
    assert_selector("#{MainbodySelect} tr", minimum: 50)
    
    # Grab first row text
    first_row = first("#{MainbodySelect} tr")
    first_row_text = first_row.all('td').map(&:text).drop(1)

    # check pager text
    assert_text('Showing 1 to 50 of 400 entries')

    # check pager object
    pager_select = 'div#job_status_table_paginate'
    assert_selector(pager_select)

    # check highlight
    assert_selector("#{pager_select} li.active", text: '1')

    # Show next page
    find("#{pager_select} li", text: '2').click

    # Finish loading
    assert_selector("#{MainbodySelect} tr", minimum: 50)

    # Ensure rows changed
    new_row = first("#{MainbodySelect} tr")
    new_row_text = new_row.all('td').map(&:text).drop(1)

    # Ensure highlight changed
    assert_selector("#{pager_select} li.active", text: '2')

    # Ensure text changed
    assert_text('Showing 51 to 100 of 400 entries')
  end
end