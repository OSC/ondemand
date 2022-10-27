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
    # max starts out at 7
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal 7, find_max('bc_num_slots')
    assert_equal 3, find_min('bc_num_slots')
    select('owens', from: bc_ele_id('cluster'))

    # change the node type and we should have some new min/max & value
    select('gpu', from: bc_ele_id('node_type'))
    assert_equal 28, find_max('bc_num_slots')
    assert_equal 2, find_min('bc_num_slots')
    assert_equal '2', find_value('bc_num_slots')

    select('hugemem', from: bc_ele_id('node_type'))
    assert_equal 42, find_max('bc_num_slots')
    assert_equal 42, find_min('bc_num_slots')
    assert_equal '42', find_value('bc_num_slots')
  end

  test 'clamping works on maxes' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    
    # defaults
    assert_equal 7, find_max('bc_num_slots')
    assert_equal 3, find_min('bc_num_slots')
    assert_equal 'any', find_value('node_type')

    # put the max for 'any'
    fill_in bc_ele_id('bc_num_slots'), with: 7

    # now toggle to gpu. Max is 28 and the value is 28
    select('gpu', from: bc_ele_id('node_type'))
    assert_equal 28, find_max('bc_num_slots')
    assert_equal '28', find_value('bc_num_slots')
  end

  test 'clamping works on mins' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    
    # defaults
    assert_equal 7, find_max('bc_num_slots')
    assert_equal 3, find_min('bc_num_slots')
    assert_equal 'any', find_value('node_type')

    # put the min for 'any'
    fill_in bc_ele_id('bc_num_slots'), with: 3

    # now toggle to gpu. min is 2 and the value is 2
    select('gpu', from: bc_ele_id('node_type'))
    assert_equal 2, find_min('bc_num_slots')
    assert_equal '2', find_value('bc_num_slots')
  end

  test 'clamping shifts left' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    
    # setup to start with same
    select('same', from: bc_ele_id('node_type'))
    assert_equal 200, find_max('bc_num_slots')
    assert_equal 100, find_min('bc_num_slots')

    # less than current max, but greater than the next choices'
    fill_in bc_ele_id('bc_num_slots'), with: 150
    
    # toggle back to 'gpu' and it should clamp to 150 down to 28
    select('gpu', from: bc_ele_id('node_type'))
    assert_equal 28, find_max('bc_num_slots')
    assert_equal '28', find_value('bc_num_slots')
  end

  test 'clamping shifts right' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    
    # start with defaults
    assert_equal 3, find_min('bc_num_slots')
    assert_equal 7, find_max('bc_num_slots')
    assert_equal 'any', find_value('node_type')

    # not the max, but less than the next choices'
    fill_in bc_ele_id('bc_num_slots'), with: 18

    # toggle back to 'oakley' and it should clamp 18 up to 100 (same's minimum)
    select('same', from: bc_ele_id('node_type'))
    assert_equal 100, find_min('bc_num_slots')
    assert_equal '100', find_value('bc_num_slots')
  end

  test 'changing the cluster changes max' do
    # max starts out at 7
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal 7, find_max('bc_num_slots')
    select('owens', from: bc_ele_id('cluster'))

    select('gpu', from: bc_ele_id('node_type'))
    assert_equal 28, find_max('bc_num_slots')

    # changing the cluster changes the max
    select('oakley', from: bc_ele_id('cluster'))
    assert_equal 40, find_max('bc_num_slots')
  end

  test 'using same node sets min/max' do
    # max starts out at 7
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal 7, find_max('bc_num_slots')

    select('same', from: bc_ele_id('node_type'))
    assert_equal 100, find_min('bc_num_slots')
    assert_equal 200, find_max('bc_num_slots')
    assert_equal '100', find_value('bc_num_slots')

    # toggle the cluster back and forth and it's still the same
    select('oakley', from: bc_ele_id('cluster'))
    select('owens', from: bc_ele_id('cluster'))
    assert_equal 100, find_min('bc_num_slots')
    assert_equal 200, find_max('bc_num_slots')
    assert_equal '100', find_value('bc_num_slots')

    select('oakley', from: bc_ele_id('cluster'))
    assert_equal 100, find_min('bc_num_slots')
    assert_equal 200, find_max('bc_num_slots')
    assert_equal '100', find_value('bc_num_slots')
  end

  test 'can set multiple min/maxes' do
    # ensure defaults
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal 1, find_min('bc_num_hours')
    assert_equal 20, find_max('bc_num_hours')
    assert_equal 3, find_min('bc_num_slots')
    assert_equal 7, find_max('bc_num_slots')
    assert_equal 'any', find_value('node_type')

    # changing the same node changes both bc_num_slots and bc_num_hours
    select('same', from: bc_ele_id('node_type'))
    assert_equal 100, find_min('bc_num_slots')
    assert_equal 200, find_max('bc_num_slots')
    assert_equal 444, find_min('bc_num_hours')
    assert_equal 555, find_max('bc_num_hours')
  end

  test 'can set multiple min/maxes with for clauses' do
    # ensure defaults
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal 1, find_min('bc_num_hours')
    assert_equal 20, find_max('bc_num_hours')
    assert_equal 3, find_min('bc_num_slots')
    assert_equal 7, find_max('bc_num_slots')
    assert_equal 'any', find_value('node_type')
    assert_equal 'owens', find_value('cluster')

    # changing to the gpu node changes both bc_num_slots and bc_num_hours
    select('gpu', from: bc_ele_id('node_type'))
    assert_equal 2, find_min('bc_num_slots')
    assert_equal 28, find_max('bc_num_slots')
    assert_equal 80, find_min('bc_num_hours')
    assert_equal 88, find_max('bc_num_hours')

    # change the cluster and these change again (the for clause)
    select('oakley', from: bc_ele_id('cluster'))
    assert_equal 3, find_min('bc_num_slots')
    assert_equal 40, find_max('bc_num_slots')
    assert_equal 90, find_min('bc_num_hours')
    assert_equal 99, find_max('bc_num_hours')
  end

  test 'nothing applied to broken node type' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal 7, find_max('bc_num_slots')
    assert_equal 3, find_min('bc_num_slots')
    assert_equal '3', find_value('bc_num_slots')
    select('broken', from: bc_ele_id('node_type'))

    # changing clusters does nothing.
    select('owens', from: bc_ele_id('cluster'))
    assert_equal 7, find_max('bc_num_slots')
    assert_equal 3, find_min('bc_num_slots')
    assert_equal '3', find_value('bc_num_slots')

    select('oakley', from: bc_ele_id('cluster'))
    assert_equal 7, find_max('bc_num_slots')
    assert_equal 3, find_min('bc_num_slots')
    assert_equal '3', find_value('bc_num_slots')

    # choose same to get a min & max set. Change back to
    # broken and we keep the same min & max from same.
    # TODO this is _current_ behaviour, will probably break
    select('same', from: bc_ele_id('node_type'))
    assert_equal 200, find_max('bc_num_slots')
    assert_equal 100, find_min('bc_num_slots')
    assert_equal '100', find_value('bc_num_slots')
    select('broken', from: bc_ele_id('node_type'))
    assert_equal 200, find_max('bc_num_slots')
    assert_equal 100, find_min('bc_num_slots')
    assert_equal '100', find_value('bc_num_slots')
  end

  test 'clamp min values' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal '3', find_value('bc_num_slots')

    select('owens', from: bc_ele_id('cluster'))
    select('gpu', from: bc_ele_id('node_type'))
    # value gets set to the new min
    assert_equal '2', find_value('bc_num_slots')

    # change clusters and it bumps up again
    select('oakley', from: bc_ele_id('cluster'))
    assert_equal '3', find_value('bc_num_slots')

    # edit the values, then change the cluster to ensure
    # the change overwrites the edit
    fill_in bc_ele_id('bc_num_slots'), with: 1
    assert_equal '1', find_value('bc_num_slots')
    select('owens', from: bc_ele_id('cluster'))
    assert_equal '2', find_value('bc_num_slots')
  end

  test 'clamp max values' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal '3', find_value('bc_num_slots')
    # this tests filling values by design, bc we have to set a giant max right off the bat
    fill_in bc_ele_id('bc_num_slots'), with: 1000
    assert_equal '1000', find_value('bc_num_slots')

    select('owens', from: bc_ele_id('cluster'))
    select('gpu', from: bc_ele_id('node_type'))
    # value gets set to the new max
    assert_equal '28', find_value('bc_num_slots')

    # change clusters and it bumps up again
    select('oakley', from: bc_ele_id('cluster'))
    assert_equal '40', find_value('bc_num_slots')
  end

  test 'python choice sets account' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal 'python27', find_value('bc_account')

    select('3.1', from: bc_ele_id('python_version'))
    assert_equal 'python31', find_value('bc_account')

    select('2.7', from: bc_ele_id('python_version'))
    assert_equal 'python27', find_value('bc_account')

    select('3.2', from: bc_ele_id('python_version'))
    assert_equal 'python32', find_value('bc_account')

    # 3.7 isn't configured to change the account, so it stays 3.2
    select('3.7', from: bc_ele_id('python_version'))
    assert_equal 'python32', find_value('bc_account')
  end

  test 'python choice sets hidden change thing' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    select('advanced', from: bc_ele_id('node_type'))
    assert_equal 'default', find_value('hidden_change_thing', visible: false)

    select('3.1', from: bc_ele_id('python_version'))
    assert_equal 'python31', find_value('bc_account')
    assert_equal 'default', find_value('hidden_change_thing', visible: false)

    select('3.6', from: bc_ele_id('python_version'))
    assert_equal 'python36', find_value('hidden_change_thing', visible: false)

    select('3.7', from: bc_ele_id('python_version'))
    assert_equal 'python37', find_value('hidden_change_thing', visible: false)

    select('4.0.nightly', from: bc_ele_id('python_version'))
    assert_equal 'python4nightly', find_value('hidden_change_thing', visible: false)
  end

  test 'inline edits dont affect updating values' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal 'python27', find_value('bc_account')

    select('3.1', from: bc_ele_id('python_version'))
    assert_equal 'python31', find_value('bc_account')

    # insert some text into the field
    account_element = find("##{bc_ele_id('bc_account')}")
    account_element.send_keys " & some typed value"
    assert_equal 'python31 & some typed value', find_value('bc_account')

    # now change it and confirm the value
    select('3.2', from: bc_ele_id('python_version'))
    assert_equal 'python32', find_value('bc_account')
  end

  test 'inline changes to hidden fields get overwritten too' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal 'default', find_value('hidden_change_thing')

    select('3.7', from: bc_ele_id('python_version'))
    assert_equal 'python37', find_value('hidden_change_thing', visible: false)

    update_script = <<~JAVASCRIPT
      let ele = document.getElementById('batch_connect_session_context_hidden_change_thing');
      ele.value = 'some new value';
    JAVASCRIPT

    execute_script(update_script)
    assert_equal 'some new value', find_value('hidden_change_thing', visible: false)

    select('4.0.nightly', from: bc_ele_id('python_version'))
    assert_equal 'python4nightly', find_value('hidden_change_thing', visible: false)
  end

  test 'hiding cuda version' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')

    # default is any, so we can't see cuda_version
    assert_equal 'any', find_value('node_type')
    assert !find("##{bc_ele_id('cuda_version')}", visible: false).visible?

    # select gpu and you can
    select('gpu', from: bc_ele_id('node_type'))
    assert find("##{bc_ele_id('cuda_version')}").visible?

    # toggle back to 'same' and it's gone
    select('same', from: bc_ele_id('node_type'))
    assert !find("##{bc_ele_id('cuda_version')}", visible: false).visible?
  end

  # similar to the use case above, but for https://github.com/OSC/ondemand/issues/1666
  test 'hiding a second option' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')

    # default is any, so we can't see cuda_version or advanced_options
    assert_equal 'any', find_value('node_type')
    assert !find("##{bc_ele_id('cuda_version')}", visible: false).visible?
    assert !find("##{bc_ele_id('advanced_options')}", visible: false).visible?

    # gpu shows both cuda_version and advanced_options
    select('gpu', from: bc_ele_id('node_type'))
    assert find("##{bc_ele_id('cuda_version')}").visible?
    assert find("##{bc_ele_id('advanced_options')}").visible?

    # toggle back to 'same' and both are gone
    select('same', from: bc_ele_id('node_type'))
    assert !find("##{bc_ele_id('cuda_version')}", visible: false).visible?
    assert !find("##{bc_ele_id('advanced_options')}", visible: false).visible?

    # now select advanced and cuda is hidden, but advanced is shown
    select('advanced', from: bc_ele_id('node_type'))
    assert !find("##{bc_ele_id('cuda_version')}", visible: false).visible?
    assert find("##{bc_ele_id('advanced_options')}").visible?
  end

  test 'options with hyphens set min & max' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')

    # defaults
    assert_equal 'owens', find_value('cluster')
    assert_equal 'any', find_value('node_type')
    assert_equal 7, find_max('bc_num_slots')

    select('other-40ish-option', from: bc_ele_id('node_type'))
    assert_equal 40, find_max('bc_num_slots')

    # now change the cluster and the max changes
    select('oakley', from: bc_ele_id('cluster'))
    assert_equal 48, find_max('bc_num_slots')
  end

  test 'options with hyphens get hidden' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')

    # defaults
    assert_equal 'owens', find_value('cluster')
    assert_equal 'any', find_value('node_type')
    assert_equal '2.7', find_value('python_version')

    # now switch node type and find that 2.7, and more, are hidden and 3.6 is the choice now
    # even when the options has hyphens in it
    select('other-40ish-option', from: bc_ele_id('node_type'))
    assert_equal 'display: none;', find_option_style('python_version', '2.7')
    assert_equal 'display: none;', find_option_style('python_version', '3.1')
    assert_equal 'display: none;', find_option_style('python_version', '3.2')
    assert_equal '3.6', find("##{bc_ele_id('python_version')}").value
  end

  test 'options with numbers and slashes' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')

    # defaults
    assert_equal 'physics_1234', find_value('classroom')
    assert_equal 'small', find_value('classroom_size')
    assert_equal '', find_option_style('classroom_size', 'medium')
    assert_equal '', find_option_style('classroom_size', 'large')

    # now change the classroom and see the other sizes disappear
    select('Astronomy 5678', from: bc_ele_id('classroom'))
    assert_equal 'display: none;', find_option_style('classroom_size', 'medium')
    assert_equal 'display: none;', find_option_style('classroom_size', 'large')

    # go back to default
    select('Physics 1234', from: bc_ele_id('classroom'))
    assert_equal 'physics_1234', find_value('classroom')
    assert_equal 'small', find_value('classroom_size')
    assert_equal '', find_option_style('classroom_size', 'medium')
    assert_equal '', find_option_style('classroom_size', 'large')

    # choose the option with slashes, and large and medium are gone
    select('Economics 8846', from: bc_ele_id('classroom'))
    assert_equal 'small', find_value('classroom_size')
    assert_equal 'display: none;', find_option_style('classroom_size', 'medium')
    assert_equal 'display: none;', find_option_style('classroom_size', 'large')
  end
end
