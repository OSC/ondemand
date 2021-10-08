# frozen_string_literal: true

require 'application_system_test_case'

class BatchConnectTest < ApplicationSystemTestCase
  def setup
    stub_sys_apps
    Configuration.stubs(:bc_dynamic_js?).returns(true)
  end

  test 'cluster choice changes node types' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')

    # select oakley and 2 node types should be hidden
    select('oakley', from: bc_ele_id('cluster'))

    # FIXME: no idea why .visible? doesn't work here. Selenium/chrome native still shows element as visible?
    assert_equal 'display: none;', find_option_style('node_type', 'advanced')
    assert_equal 'display: none;', find_option_style('node_type', 'hugemem')

    # select owens and now they're available
    select('owens', from: bc_ele_id('cluster'))
    assert_equal '', find_option_style('node_type', 'advanced')
    assert_equal '', find_option_style('node_type', 'hugemem')
  end

  test 'node type choice changes python versions' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')

    # select python 2.7 to initialize things
    select('owens', from: bc_ele_id('cluster'))
    select('any', from: bc_ele_id('node_type'))
    select('2.7', from: bc_ele_id('python_version'))
    assert_equal '', find_option_style('python_version', '2.7')

    # now switch node type and find that 2.7, and more, are hidden and 3.6 is the choice now
    select('advanced', from: bc_ele_id('node_type'))
    assert_equal 'display: none;', find_option_style('python_version', '2.7')
    assert_equal 'display: none;', find_option_style('python_version', '3.1')
    assert_equal 'display: none;', find_option_style('python_version', '3.2')
    assert_equal '3.6', find("##{bc_ele_id('python_version')}").value
  end

  test 'changing node type changes mins & maxs' do
    # max starts out at 20
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal 20, find_max('bc_num_slots')
    assert_equal 1, find_min('bc_num_slots')
    select('owens', from: bc_ele_id('cluster'))

    # change the node type and we should have some new max
    select('gpu', from: bc_ele_id('node_type'))
    assert_equal 28, find_max('bc_num_slots')
    assert_equal 2, find_min('bc_num_slots')

    select('hugemem', from: bc_ele_id('node_type'))
    assert_equal 42, find_max('bc_num_slots')
    assert_equal 42, find_min('bc_num_slots')
  end

  # TODO: make this test work
  # test 'changing the cluster changes max' do
  #   # max starts out at 20
  #   visit new_batch_connect_session_context_url('sys/bc_jupyter')
  #   assert_equal 20, find_max('bc_num_slots')
  #   select('owens', from: bc_ele_id('cluster'))

  #   select('gpu', from: bc_ele_id('node_type'))
  #   assert_equal 28, find_max('bc_num_slots')

  #   # changing the cluster changes the max
  #   select('oakley', from: bc_ele_id('cluster'))
  #   assert_equal 40, find_max('bc_num_slots')
  # end
end
