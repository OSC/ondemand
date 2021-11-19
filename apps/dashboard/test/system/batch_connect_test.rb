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

  test 'changing the cluster changes max' do
    # max starts out at 20
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal 20, find_max('bc_num_slots')
    select('owens', from: bc_ele_id('cluster'))

    select('gpu', from: bc_ele_id('node_type'))
    assert_equal 28, find_max('bc_num_slots')

    # changing the cluster changes the max
    select('oakley', from: bc_ele_id('cluster'))
    assert_equal 40, find_max('bc_num_slots')
  end

  test 'using same node sets min/max' do
    # max starts out at 20
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal 20, find_max('bc_num_slots')

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

  test 'nothing applied to any node type' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal 20, find_max('bc_num_slots')
    assert_equal 1, find_min('bc_num_slots')
    assert_equal '1', find_value('bc_num_slots')

    # changing clusters does nothing.
    select('owens', from: bc_ele_id('cluster'))
    select('any', from: bc_ele_id('node_type'))
    assert_equal 20, find_max('bc_num_slots')
    assert_equal 1, find_min('bc_num_slots')
    assert_equal '1', find_value('bc_num_slots')

    select('oakley', from: bc_ele_id('cluster'))
    assert_equal 20, find_max('bc_num_slots')
    assert_equal 1, find_min('bc_num_slots')
    assert_equal '1', find_value('bc_num_slots')

    # choose same to get a min & max set. Change back to
    # any and we keep the same min & max from same.
    # TODO this is _current_ behaviour, will probably break
    select('same', from: bc_ele_id('node_type'))
    assert_equal 200, find_max('bc_num_slots')
    assert_equal 100, find_min('bc_num_slots')
    assert_equal '100', find_value('bc_num_slots')
    select('any', from: bc_ele_id('node_type'))
    assert_equal 200, find_max('bc_num_slots')
    assert_equal 100, find_min('bc_num_slots')
    assert_equal '100', find_value('bc_num_slots')
  end

  test 'clamp min values' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal '1', find_value('bc_num_slots')

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
    assert_equal '1', find_value('bc_num_slots')
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
      let ele = $('#batch_connect_session_context_hidden_change_thing');
      ele.val('some new value');
      ele.attr('value', 'some new value');
    JAVASCRIPT

    execute_script(update_script)
    assert_equal 'some new value', find_value('hidden_change_thing', visible: false)

    select('4.0.nightly', from: bc_ele_id('python_version'))
    assert_equal 'python4nightly', find_value('hidden_change_thing', visible: false)
  end

  test 'sessions respond to cache file' do
    Dir.mktmpdir('bc_cache_test') do |tmpdir|
      OodAppkit.stubs(:dataroot).returns(Pathname.new(tmpdir.to_s))


      visit new_batch_connect_session_context_url('sys/bc_jupyter')
      puts  find("##{bc_ele_id('cluster')}")['innerHTML']
      assert_equal 'owens', find_value('cluster')
      assert_equal 'any', find_value('node_type')
      assert_equal '2.7', find_value('python_version')

      cache_json = File.new("#{BatchConnect::Session.cache_root}/sys_bc_jupyter.json", 'w+')
      cache_json.write({ cluster: 'oakley', node_type: 'gpu', python_version: '3.2' }.to_json)
      cache_json.close

      visit new_batch_connect_session_context_url('sys/bc_jupyter')
      assert_equal 'oakley', find_value('cluster')
      assert_equal 'gpu', find_value('node_type')
      assert_equal '3.2', find_value('python_version')
    end
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
end
