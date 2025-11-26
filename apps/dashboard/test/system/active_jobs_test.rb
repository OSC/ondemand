# frozen_string_literal: true

require 'application_system_test_case'
require 'ood_core/job/adapters/slurm'

class ActiveJobsTest < ApplicationSystemTestCase
  # Set alias
  NodeInfo = OodCore::Job::NodeInfo

  DETAILS_HEADERS = [
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
  MAIN_BODY_SELECT = '#job_status_table tbody'
  PAGER_SELECT = 'div#job_status_table_paginate'
  
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
        status:          :completed
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

  def prepare_many_jobs(multiplier:)
    # duplicate jobs and fix id overlap
    current_jobs = OodCore::Job::Adapter.new.info_all_each
    id = 0
    new_jobs = (current_jobs*multiplier).map do |job|
      id += 1
      OodCore::Job::Info.new(**job.to_h.merge({id: id.to_s}))
    end
    OodCore::Job::Adapter.any_instance.stubs(:info_all_each).returns(new_jobs)
  end

  test 'defaults to your jobs' do
    visit active_jobs_url
    
    # Finish loading
    assert_selector("#{MAIN_BODY_SELECT} tr", minimum: 2)
    # The UI should default to the "Your Jobs" filter
    assert_selector('#selected-filter-label', text: 'Your Jobs')
    # The list should have exactly two jobs in it
    rows = all("#{MAIN_BODY_SELECT} tr")
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
      'Completed',
      'Oakley',
      ''   
    ]
    assert_equal 9, second_row_text.length
    assert_equal expected_sr, second_row_text

    # Check buttons
    button_select = "#{MAIN_BODY_SELECT} .details-control"
    assert_equal 2, all(button_select).length

    # Click buttons
    all(button_select).map(&:click)
    

    # Wait for load
    details_select = "#{MAIN_BODY_SELECT} div.panel.panel-default"
    assert_selector("#{details_select} tr")
    
    # Confirm details
    card_header_items = all("#{details_select} div.card-header span")
    exp_header_data = ['Queued', 'Sample2', '345']
    assert_equal exp_header_data, card_header_items.map(&:text)

    headers = all("#{details_select} div.card-body td.col-xs-2")
    details = all("#{details_select} div.card-body td.col-xs-10")

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

    assert_equal DETAILS_HEADERS, headers.map(&:text)
    assert_equal exp_details, details.map(&:text)

    assert_selector('div.alert-warning')
  end


  test 'refreshes when filter is switched' do
    visit active_jobs_url#(cluster_id: 'all')

    # Finish loading
    assert_selector("#{MAIN_BODY_SELECT} tr", count: 2)

    # Open the filters dropdown (first group is filters)
    first('div.btn-group').find('button.dropdown-toggle').click
    click_on 'All Jobs'

    # The page should reload with the new filter in the query string
    assert_match(/jobfilter=all/, page.current_url)
    assert_selector('#selected-filter-label', text: 'All Jobs')

    # Check number of rows
    assert_selector("#{MAIN_BODY_SELECT} tr", count: 4)

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
    prepare_many_jobs(multiplier: 100)

    visit active_jobs_url(jobfilter:'all')

    # Finish loading
    assert_selector("#{MAIN_BODY_SELECT} tr", count: 50)
    
    # Grab first row text
    first_row = first("#{MAIN_BODY_SELECT} tr")
    first_row_text = first_row.all('td').map(&:text).drop(1)

    # check pager text
    assert_text('Showing 1 to 50 of 400 entries')

    # check pager object
    assert_selector(PAGER_SELECT)

    # check highlight and prev button
    assert_selector("#{PAGER_SELECT} li.active", text: '1')
    assert_selector("#{PAGER_SELECT} li.paginate_button.disabled", text: 'Previous')

    # Show next page and repeat
    find("#{PAGER_SELECT} li", text: '2').click

    assert_selector("#{MAIN_BODY_SELECT} tr", count: 50)
    new_row = first("#{MAIN_BODY_SELECT} tr")
    new_row_text = new_row.all('td').map(&:text).drop(1)
    assert_selector("#{PAGER_SELECT} li.active", text: '2')
    refute_selector("#{PAGER_SELECT} li.paginate_button.previous.disabled")
    refute_selector("#{PAGER_SELECT} li.paginate_button.next.disabled")
    assert_text('Showing 51 to 100 of 400 entries')

    # click next button and repeat
    find("#{PAGER_SELECT} li", text: 'Next').click
    assert_selector("#{MAIN_BODY_SELECT} tr", count: 50)
    assert_selector("#{PAGER_SELECT} li.active", text: '3')
    assert_text('Showing 101 to 150 of 400 entries')

    # Click last page
    find("#{PAGER_SELECT} li", text: '8').click
    assert_selector("#{MAIN_BODY_SELECT} tr", count: 50)
    assert_selector("#{PAGER_SELECT} li.active", text: '8')
    assert_selector("#{PAGER_SELECT} li.paginate_button.disabled", text: 'Next') 
    assert_text('Showing 351 to 400 of 400 entries')

    # Click prev button
    find("#{PAGER_SELECT} li", text: 'Previous').click
    assert_selector("#{MAIN_BODY_SELECT} tr", count: 50)
    assert_selector("#{PAGER_SELECT} li.active", text: '7')
    assert_text('Showing 301 to 350 of 400 entries')
  end

  test 'results-per-page setting works' do
    prepare_many_jobs(multiplier: 150)

    visit active_jobs_url(jobfilter: 'all')

    res_per_page_selector = 'div#job_status_table_length select'
    assert_selector(res_per_page_selector, text: '50')
    assert_selector("#{MAIN_BODY_SELECT} tr", count: 50)
    assert_text('Showing 1 to 50 of 600 entries')
    assert_selector("#{PAGER_SELECT} li", text: '12')

    # Change setting
    find(res_per_page_selector).click
    find("#{res_per_page_selector} option[value='10']").click
    assert_selector(res_per_page_selector, text: '10')
    assert_selector("#{MAIN_BODY_SELECT} tr", count: 10)
    assert_text('Showing 1 to 10 of 600 entries')
    assert_selector("#{PAGER_SELECT} li", text: '60')

    # Change setting
    find(res_per_page_selector).click
    find("#{res_per_page_selector} option[value='25']").click
    assert_selector(res_per_page_selector, text: '25')
    assert_selector("#{MAIN_BODY_SELECT} tr", count: 25)
    assert_text('Showing 1 to 25 of 600 entries')
    assert_selector("#{PAGER_SELECT} li", text: '24')

    # Move page and select setting
    find("#{PAGER_SELECT} li", text: '5').click
    assert_text('Showing 101 to 125 of 600 entries')
    # Now changes should stay starting at 101
    find(res_per_page_selector).click
    find("#{res_per_page_selector} option[value='50']").click
    assert_text('Showing 101 to 150 of 600 entries')
    assert_selector("#{PAGER_SELECT} li.active", text: '3')

    # Use all setting
    find(res_per_page_selector).click
    find("#{res_per_page_selector} option[value='-1']").click
    assert_selector(res_per_page_selector, text: 'All')
    assert_selector("#{MAIN_BODY_SELECT} tr", count: 600)
    assert_text('Showing 1 to 600 of 600 entries')
    assert_selector("#{PAGER_SELECT} li.active", text: '1')
    refute_selector("#{PAGER_SELECT} li", text: '2')
  end

  test 'text filter works' do
    visit active_jobs_url(jobfilter: 'all')

    # Verify filter input is rendered
    filter_selector = 'div#job_status_table_filter input'
    assert_selector(filter_selector)

    # Verify filter reads ids
    find(filter_selector).set('345')
    # Wait for load
    assert_selector("#{MAIN_BODY_SELECT} tr")
    assert_text '345'
    assert_text 'Sample2'
    assert_text 'account2'

    # Verify filter reads job names
    find(filter_selector).set('Sample4')
    assert_selector("#{MAIN_BODY_SELECT} tr")
    assert_text '789'
    assert_text 'Sample4'
    assert_text 'account4'

    # Verify filter reads users
    find(filter_selector).set('not_')
    assert_selector("#{MAIN_BODY_SELECT} tr", count: 2)
    assert_text '123'
    assert_text 'Sample1'
    assert_text 'account1'
    assert_text '789'
    assert_text 'Sample4'
    assert_text 'account4'

    # Verify filter reads accounts
    find(filter_selector).set('account3')
    assert_selector("#{MAIN_BODY_SELECT} tr", count: 1)
    assert_text '567'
    assert_text 'Sample3'
    assert_text 'account3'

    # Verify filter reads queue
    find(filter_selector).set('normal')
    assert_selector("#{MAIN_BODY_SELECT} tr", count: 1)
    assert_text '123'
    assert_text 'Sample1'
    assert_text 'account1'

    # Verify filter reads status
    find(filter_selector).set('queue')
    assert_selector("#{MAIN_BODY_SELECT} tr", count: 2)
    assert_text '345'
    assert_text 'Sample2'
    assert_text 'account2'
    assert_text '789'
    assert_text 'Sample4'
    assert_text 'account4'
    
    
    # Verify filter finds text in middle/end of string
    find(filter_selector).set('ple1')
    assert_selector("#{MAIN_BODY_SELECT} tr", count: 1)
    assert_text '123'
    assert_text 'Sample1'
    assert_text 'account1'
  end
end
