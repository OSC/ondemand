# frozen_string_literal: true

require 'application_system_test_case'
require 'ood_core/job/adapters/slurm'

class BatchConnectTest < ApplicationSystemTestCase
  def setup
    stub_sys_apps
    stub_user
    Configuration.stubs(:bc_dynamic_js).returns(true)
    Configuration.stubs(:bc_dynamic_js?).returns(true) # stub the alias too
  end

  def stub_git(dir)
    Open3.stubs(:capture3)
         .with('git', 'describe', '--always', '--tags', chdir: dir)
         .returns(['1.2.3', '', exit_success])
  end

  def make_bc_app(dir, form)
    SysRouter.stubs(:base_path).returns(Pathname.new(dir))
    app_dir = "#{dir}/app".tap { |d| Dir.mkdir(d) }
    stub_scontrol
    stub_sacctmgr
    stub_git(app_dir)
    Pathname.new(app_dir).join('form.yml').write(form)
  end

  def stub_good_launch(dir)
    Configuration.stubs(:user_settings_file).returns(Pathname.new("#{dir}/settings.yml"))
    BatchConnect::Session.any_instance.stubs(:save).returns(true)
    BatchConnect::Session.any_instance.stubs(:job_id).returns('job-id-123')
    BatchConnect::Session.stubs(:cache_root).returns(Pathname.new(dir))
    OodCore::Job::Adapters::Slurm.any_instance
                                 .stubs(:info)
                                 .returns(OodCore::Job::Info.new(id: 'job-id-123', status: :running))
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

  test 'several elements can set min/max' do
    # here we see that changing the node_type can set min & max on bc_num_hours
    # but changing classroom can also set min & max on bc_num_hours

    # ensure defaults
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal 1, find_min('bc_num_hours')
    assert_equal 20, find_max('bc_num_hours')
    assert_equal 'any', find_value('node_type')
    assert_equal 'physics_1234', find_value('classroom')
    assert_equal 'owens', find_value('cluster')

    # changing the node type sets mins & maxes
    select('same', from: bc_ele_id('node_type'))
    assert_equal 444, find_min('bc_num_hours')
    assert_equal 555, find_max('bc_num_hours')

    select('Astronomy 5678', from: bc_ele_id('classroom'))
    assert_equal 100, find_min('bc_num_hours')
    assert_equal 110, find_max('bc_num_hours')
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

  test 'clamp zeros' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal '0', find_value('gpus')
    assert_equal 'any', find_value('node_type')

    # change to gpu node type and 0 is clamped to 1 (gpu's min)
    select('gpu', from: bc_ele_id('node_type'))
    assert_equal '1', find_value('gpus')

    fill_in bc_ele_id('gpus'), with: 3
    assert_equal '3', find_value('gpus')

    # change back to any node type and 3 is clamped to 0 (any's min)
    select('any', from: bc_ele_id('node_type'))
    assert_equal '0', find_value('gpus')
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

  # test case for https://github.com/OSC/ondemand/issues/2686
  test 'python choice also sets near duplicate field bc_account_other' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal 'python27', find_value('bc_account')
    assert_equal 'other_account_python27', find_value('bc_account_other')

    select('3.1', from: bc_ele_id('python_version'))
    assert_equal 'python31', find_value('bc_account')
    assert_equal 'other_account_python31', find_value('bc_account_other')

    select('2.7', from: bc_ele_id('python_version'))
    assert_equal 'python27', find_value('bc_account')
    assert_equal 'other_account_python27', find_value('bc_account_other')

    select('3.2', from: bc_ele_id('python_version'))
    assert_equal 'python32', find_value('bc_account')
    assert_equal 'other_account_python32', find_value('bc_account_other')

    # 3.7 isn't configured to change the account, so it stays 3.2
    select('3.7', from: bc_ele_id('python_version'))
    assert_equal 'python32', find_value('bc_account')
    assert_equal 'other_account_python32', find_value('bc_account_other')
  end

  test 'python choice sets hidden change thing' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')

    # defaults
    assert_equal '2.7', find_value('python_version')
    assert_equal 'any', find_value('node_type')
    assert_equal 'default', find_value('hidden_change_thing', visible: false)

    select('advanced', from: bc_ele_id('node_type'))
    assert_equal 'python36', find_value('hidden_change_thing', visible: false)

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
    account_element.send_keys ' & some typed value'
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

  test 'sessions respond to cache file' do
    Dir.mktmpdir('bc_cache_test') do |tmpdir|
      OodAppkit.stubs(:dataroot).returns(Pathname.new(tmpdir.to_s))

      visit new_batch_connect_session_context_url('sys/bc_jupyter')
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

  test 'hiding using check boxes based on when checked' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - gpus
          - checkbox_test
        attributes:
          gpus:
            widget: 'number_field'
          checkbox_test:
            widget: 'check_box'
            html_options:
              data:
                hide-gpus-when-checked: true
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      visit new_batch_connect_session_context_url('sys/app')

      # defaults
      refute(find("##{bc_ele_id('checkbox_test')}").checked?)
      assert(find("##{bc_ele_id('gpus')}").visible?)

      # check the checkbox, and 'gpus' is hidden
      check(bc_ele_id('checkbox_test'))
      refute(find("##{bc_ele_id('gpus')}", visible: :hidden).visible?)

      # un-check the checkbox, and 'gpus' is back
      uncheck(bc_ele_id('checkbox_test'))
      assert(find("##{bc_ele_id('gpus')}").visible?)
    end
  end

  test 'hiding using check boxes based on when unchecked' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - gpus
          - checkbox_test
        attributes:
          gpus:
            widget: 'number_field'
          checkbox_test:
            widget: 'check_box'
            html_options:
              data:
                hide-gpus-when-not-checked: true
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      visit new_batch_connect_session_context_url('sys/app')

      # defaults
      refute(find("##{bc_ele_id('checkbox_test')}").checked?)
      refute(find("##{bc_ele_id('gpus')}", visible: :hidden).visible?)

      # check the checkbox, and 'gpus' is visible
      check(bc_ele_id('checkbox_test'))
      assert(find("##{bc_ele_id('gpus')}").visible?)

      # un-check the checkbox, and 'gpus' is back to being hidden
      uncheck(bc_ele_id('checkbox_test'))
      refute(find("##{bc_ele_id('gpus')}", visible: :hidden).visible?)
    end
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

  test 'help menus get hidden' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')

    # defaults
    assert_equal 'any', find_value('node_type')
    find("##{bc_ele_id('bc_email_on_started')}")
    find('p', text: 'this is a help message should be hidden, sometimes', visible: true)

    select('hugemem', from: bc_ele_id('node_type'))
    find('p', text: 'this is a help message should be hidden, sometimes', visible: false)
    find("##{bc_ele_id('bc_email_on_started')}", visible: false)
  end

  test 'options that start with numbers hide other options' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')

    # defaults
    assert_equal('physics_1234', find_value('classroom'))
    assert_equal('small', find_value('classroom_size'))
    assert_equal('', find_option_style('classroom_size', 'large'))

    # now change the classroom and see large dissappear
    select('123ABC', from: bc_ele_id('classroom'))
    assert_equal('display: none;', find_option_style('classroom_size', 'large'))

    # select the default, and it's back.
    select('Physics 1234', from: bc_ele_id('classroom'))
    assert_equal('', find_option_style('classroom_size', 'large'))

    # now change the lowercase classroom and see large dissappear again.
    select('456def', from: bc_ele_id('classroom'))
    assert_equal('display: none;', find_option_style('classroom_size', 'large'))
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

  test 'can hide fields with numbers and characters' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')

    # defaults - gpus_num_v100 is hidden on page load.
    assert_equal('any', find_value('node_type'))
    refute(find("##{bc_ele_id('gpus_num_v100')}", visible: false).visible?)

    # select gpu and now it's shown.
    select('gpu', from: bc_ele_id('node_type'))
    assert(find("##{bc_ele_id('gpus_num_v100')}").visible?)
  end

  test 'options can check and uncheck' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')

    # defaults
    assert_equal('small', find_value('classroom_size'))
    refute(checked?('checkbox_test'))

    # select large and it's checked
    select('large', from: bc_ele_id('classroom_size'))
    assert(checked?('checkbox_test'))

    # back to small and it's unchanged
    select('small', from: bc_ele_id('classroom_size'))
    assert(checked?('checkbox_test'))

    # now choose medium and it's un-checked
    select('medium', from: bc_ele_id('classroom_size'))
    refute(checked?('checkbox_test'))
  end

  test 'stage errors are shown' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    err_msg = 'this is a just a test for staging error messages'
    Open3.stubs(:capture2e).raises(StandardError.new(err_msg))

    # defaults
    click_on('Launch')
    verify_bc_alert('sys/bc_jupyter', I18n.t('dashboard.batch_connect_sessions_errors_staging'), err_msg)
  end

  test 'submit errors are shown' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    err_msg = BrokenAdapter::SUBMIT_ERR_MSG
    Open3.stubs(:capture2e).returns(['', exit_success])
    BatchConnect::Session.any_instance.stubs(:adapter).returns(BrokenAdapter.new)

    # defaults
    click_on('Launch')
    verify_bc_alert('sys/bc_jupyter', I18n.t('dashboard.batch_connect_sessions_errors_submission'), err_msg)
  end

  test 'save errors are shown' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')
    err_msg = 'this is a just a test for staging error messages'
    # Open3.stubs(:capture2e).returns(['', exit_failure])
    BatchConnect::Session.any_instance.stubs(:stage).raises(StandardError.new(err_msg))

    # defaults
    click_on('Launch')
    verify_bc_alert('sys/bc_jupyter', 'save', err_msg)
  end

  test 'auto generated modules are dynamic' do
    with_modified_env({ OOD_MODULE_FILE_DIR: 'test/fixtures/modules' }) do
      visit new_batch_connect_session_context_url('sys/bc_jupyter')

      # defaults, note that intel doesn't show the default version
      assert_equal 'app_jupyter', find_value('auto_modules_app_jupyter')
      assert_equal 'intel/2021.3.0', find_value('auto_modules_intel')
      assert_equal 'owens', find_value('cluster')
      # versions not available on owens
      assert_equal 'display: none;', find_option_style('auto_modules_app_jupyter', 'app_jupyter/3.1.18')
      assert_equal 'display: none;', find_option_style('auto_modules_app_jupyter', 'app_jupyter/0.35.6')
      assert_equal 'display: none;', find_option_style('auto_modules_intel', 'intel/18.0.4')

      # select oakley and now they're available
      select('oakley', from: bc_ele_id('cluster'))
      assert_equal 'app_jupyter', find_value('auto_modules_app_jupyter')
      assert_equal '', find_option_style('auto_modules_app_jupyter', 'app_jupyter/3.1.18')
      assert_equal '', find_option_style('auto_modules_app_jupyter', 'app_jupyter/0.35.6')

      # and lots of intel versions aren't
      assert_equal 'display: none;', find_option_style('auto_modules_intel', 'intel/18.0.2')
      assert_equal 'display: none;', find_option_style('auto_modules_intel', 'intel/18.0.0')
      assert_equal 'display: none;', find_option_style('auto_modules_intel', 'intel/17.0.5')
      assert_equal 'display: none;', find_option_style('auto_modules_intel', 'intel/17.0.2')
      assert_equal 'display: none;', find_option_style('auto_modules_intel', 'intel/16.0.8')
      assert_equal 'display: none;', find_option_style('auto_modules_intel', 'intel/16.0.3')
    end
  end

  test 'auto modules allow hyphens' do
    with_modified_env({ OOD_MODULE_FILE_DIR: 'test/fixtures/modules' }) do
      visit new_batch_connect_session_context_url('sys/bc_jupyter')

      # defaults to the default version
      assert_equal('netcdf-serial', find_value('auto_modules_netcdf_serial'))

      select('4.3.3.1', from: bc_ele_id('auto_modules_netcdf_serial'))
      module_value = 'netcdf-serial/4.3.3.1'
      assert_equal(module_value, find_value('auto_modules_netcdf_serial'))

      # the script.sh.erb raises the message 'context.auto_modules_netcdf_serial' (note the _ in the name)
      # which should be 'netcdf-serial/4.3.3.1'
      click_on('Launch')
      verify_bc_alert('sys/bc_jupyter', I18n.t('dashboard.batch_connect_sessions_errors_staging'), module_value)
    end
  end

  test 'auto generated modules hide hidden modules' do
    with_modified_env({ OOD_MODULE_FILE_DIR: 'test/fixtures/modules' }) do
      visit new_batch_connect_session_context_url('sys/bc_jupyter')

      # defaults, note that intel doesn't show the default version
      assert_equal 'app_jupyter', find_value('auto_modules_app_jupyter')
      assert_equal 'intel/2021.3.0', find_value('auto_modules_intel')
      assert_equal 'owens', find_value('cluster')

      # oakley has the hidden intel module 'intel/2021.4.0'
      select('oakley', from: bc_ele_id('cluster'))

      actual_options = find_all_options('auto_modules_intel', nil).map(&:text)

      # '2021.4.0' is not listed here.
      expected_options = [
        '2021.3.0', '19.1.3', '19.0.5', '19.0.3', '18.0.4', '18.0.3', '18.0.2',
        '18.0.0', '17.0.7', '17.0.5', '17.0.2', '16.0.8', '16.0.3'
      ]
      assert_equal(expected_options, actual_options)
    end
  end

  test 'auto accounts are cluster aware' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
          - oakley
        form:
          - auto_accounts
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)

      visit new_batch_connect_session_context_url('sys/app')

      # defaults
      assert_equal 'pzs0715', find_value('auto_accounts')
      assert_equal 'owens', find_value('cluster')

      # these accounts are only on owens
      assert_equal '', find_option_style('auto_accounts', 'pas1754')
      assert_equal '', find_option_style('auto_accounts', 'pas1604')

      # pzs1124 exists on both, so it's available
      assert_equal '', find_option_style('auto_accounts', 'pzs1124')

      # pzs0715 is available on oakely, so switching clusters should keep the same value.
      select('oakley', from: bc_ele_id('cluster'))
      assert_equal 'pzs0715', find_value('auto_accounts')

      # now these are hidden when oakley is chosen
      assert_equal 'display: none;', find_option_style('auto_accounts', 'pas1754')
      assert_equal 'display: none;', find_option_style('auto_accounts', 'pas1604')

      # pzs1124 exists on both, so it's still available
      assert_equal '', find_option_style('auto_accounts', 'pzs1124')
    end
  end

  test 'simple accounts are not dynamic but are full lists' do
    with_modified_env({ OOD_BC_SIMPLE_AUTO_ACCOUNTS: '1' }) do
      Dir.mktmpdir do |dir|
        "#{dir}/app".tap { |d| Dir.mkdir(d) }
        SysRouter.stubs(:base_path).returns(Pathname.new(dir))
        stub_sacctmgr
        stub_git("#{dir}/app")

        form = <<~HEREDOC
          ---
          cluster:
            - owens
            - oakley
          form:
            - auto_accounts
        HEREDOC

        Pathname.new("#{dir}/app/").join('form.yml').write(form)

        visit new_batch_connect_session_context_url('sys/app')

        assert_equal 'pzs0715', find_value('auto_accounts')
        assert_equal 'owens', find_value('cluster')

        # notice that there are no duplicates. These accounts are not cluster aware
        expected_accounts = ['pas1604', 'pas1754', 'pas1871', 'pas2051', 'pde0006', 'pzs0714', 'pzs0715', 'pzs1010',
                             'pzs1117', 'pzs1118', 'pzs1124'].to_set

        id = bc_ele_id('auto_accounts')
        actual_accounts = page.all("##{id} option").map(&:value).to_set

        assert_equal expected_accounts, actual_accounts
      end
    end
  end

  test 'auto queues are cluster aware' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
          - oakley
        form:
          - auto_queues
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)

      visit new_batch_connect_session_context_url('sys/app')

      # defaults
      assert_equal 'batch', find_value('auto_queues')
      assert_equal 'owens', find_value('cluster')

      # just a queues that exist only on oakley
      assert_equal 'display: none;', find_option_style('auto_queues', 'serial-40core')
      assert_equal 'display: none;', find_option_style('auto_queues', 'serial-48core')
      assert_equal 'display: none;', find_option_style('auto_queues', 'gpudebug-48core')

      # systems queue is not available anywhere and thus, doesn't show up at all.
      # we have no account that can submit to it, on any cluster.
      assert_selector("##{bc_ele_id('auto_queues')} option[value='systems']", count: 0)

      # batch exists on both clusters, so switching clusters does nothing
      select('oakley', from: bc_ele_id('cluster'))
      assert_equal 'batch', find_value('auto_queues')

      # now those oakley queues are available
      assert_equal '', find_option_style('auto_queues', 'serial-40core')
      assert_equal '', find_option_style('auto_queues', 'serial-48core')
      assert_equal '', find_option_style('auto_queues', 'gpudebug-48core')
    end
  end

  test 'auto queues are account aware' do
    Dir.mktmpdir do |dir|
      form = <<~HEREDOC
        ---
        cluster:
          - owens
          - oakley
        form:
          - auto_accounts
          - auto_queues
      HEREDOC

      make_bc_app(dir, form)
      visit new_batch_connect_session_context_url('sys/app')

      # defaults
      assert_equal 'batch', find_value('auto_queues')
      assert_equal 'owens', find_value('cluster')
      assert_equal 'pzs0715', find_value('auto_accounts')

      select('oakley', from: bc_ele_id('cluster'))

      # condo-osumed queues are disabled, but the backfill-serial variants are.
      assert_equal('display: none;', find_option_style('auto_queues', 'condo-osumed-cpu-40core'))
      assert_equal('display: none;', find_option_style('auto_queues', 'condo-osumed-gpu-48core'))
      assert_equal('display: none;', find_option_style('auto_queues', 'condo-osumed-gpu-quad'))
      assert_equal('', find_option_style('auto_queues', 'condo-osumed-cpu-40core-backfill-serial'))
      assert_equal('', find_option_style('auto_queues', 'condo-osumed-gpu-48core-backfill-serial'))
      assert_equal('', find_option_style('auto_queues', 'condo-osumed-gpu-quad-backfill-serial'))

      # change the account to pas2051 and now it's flipped.
      # this is becuase pas2051 is on the condo-osumed queues' allow list and
      # on the backfill variants' deny list
      select('pas2051', from: bc_ele_id('auto_accounts'))
      assert_equal('', find_option_style('auto_queues', 'condo-osumed-cpu-40core'))
      assert_equal('', find_option_style('auto_queues', 'condo-osumed-gpu-48core'))
      assert_equal('', find_option_style('auto_queues', 'condo-osumed-gpu-quad'))
      assert_equal('display: none;', find_option_style('auto_queues', 'condo-osumed-cpu-40core-backfill-serial'))
      assert_equal('display: none;', find_option_style('auto_queues', 'condo-osumed-gpu-48core-backfill-serial'))
      assert_equal('display: none;', find_option_style('auto_queues', 'condo-osumed-gpu-quad-backfill-serial'))
    end
  end

  test 'auto qos are dynamic' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
          - oakley
        form:
          - auto_qos
          - auto_accounts
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)

      visit new_batch_connect_session_context_url('sys/app')

      # defaults
      assert_equal 'pzs0715', find_value('auto_accounts')
      assert_equal 'owens-default', find_value('auto_qos')
      assert_equal 'owens', find_value('cluster')

      find_all_options('auto_qos', 'ruby-default').each do |option|
        assert_equal 'display: none;', option['style']
      end

      find_all_options('auto_qos', 'pitzer-default').each do |option|
        assert_equal 'display: none;', option['style']
      end

      # qos' available on owens cluster, but not with the selected account
      assert_equal 'display: none;', find_option_style('auto_qos', 'staff')
      assert_equal 'display: none;', find_option_style('auto_qos', 'phoenix')
      assert_equal 'display: none;', find_option_style('auto_qos', 'geophys')
      assert_equal 'display: none;', find_option_style('auto_qos', 'hal')
      assert_equal 'display: none;', find_option_style('auto_qos', 'gpt')

      # select the right account, and now they're available
      select('pzs1124', from: bc_ele_id('auto_accounts'))
      assert_equal '', find_option_style('auto_qos', 'staff')
      assert_equal '', find_option_style('auto_qos', 'phoenix')
      assert_equal '', find_option_style('auto_qos', 'geophys')
      assert_equal '', find_option_style('auto_qos', 'hal')
      assert_equal '', find_option_style('auto_qos', 'gpt')

      # but the value is still the same
      assert_equal 'owens-default', find_value('auto_qos')

      # change the cluster, and qos changes but account stays the same
      select('oakley', from: bc_ele_id('cluster'))
      assert_equal 'oakley-default', find_value('auto_qos')
      assert_equal 'pzs1124', find_value('auto_accounts')
    end
  end

  test 'path_selector works' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - path
        attributes:
          path:
            widget: 'path_selector'
            directory: "#{Rails.root}"
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      base_id = 'batch_connect_session_context_path'

      visit new_batch_connect_session_context_url('sys/app')
      click_on('Select Path')
      sleep 1

      # assert that all the rows in the table are real. It should be showing the files in Rails.root
      find("##{base_id}_path_selector_table").all('tbody tr') do |table_row|
        table_datas = table_row.all('td')
        row_text = table_datas[1].find('span').text
        real_file = Pathname.new(Rails.root).join(row_text)
        assert(real_file.exist?)
      end

      find('span', text: 'test').click
      sleep 3 # make sure the table has time to refresh
      find("##{base_id}_path_selector_button").click

      text_field = find("##{base_id}")
      assert_equal("#{Rails.root}/test", text_field.value)
    end
  end

  test 'path_selector hides hidden files by default' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - path
        attributes:
          path:
            widget: 'path_selector'
            directory: "#{dir}/app"
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      `mkdir -p #{dir}/app/.hidden_dir`
      `touch #{dir}/app/.hidden_file`
      base_id = 'batch_connect_session_context_path'

      visit new_batch_connect_session_context_url('sys/app')
      click_on('Select Path')
      sleep 1

      table_rows = find("##{base_id}_path_selector_table").all('tbody tr')
      find('span', text: 'form.yml')

      # 3 things exist in the directory - but only 1 is shown
      # the other 2 are .hidden_dir and .hidden_file
      assert_equal(3, Dir.children("#{dir}/app").size)
      assert_equal(1, table_rows.size)
    end
  end

  # similar to the test above - only it's configure to show
  # the hidden file and directory.
  test 'path_selector can show hidden files' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - path
        attributes:
          path:
            widget: 'path_selector'
            directory: "#{dir}/app"
            show_hidden: true
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      `mkdir -p #{dir}/app/.hidden_dir`
      `touch #{dir}/app/.hidden_file`
      base_id = 'batch_connect_session_context_path'

      visit new_batch_connect_session_context_url('sys/app')
      click_on('Select Path')
      sleep 1

      table_rows = find("##{base_id}_path_selector_table").all('tbody tr')
      find('span', text: 'form.yml')
      find('span', text: '.hidden_dir')

      assert_equal(3, Dir.children("#{dir}/app").size)
      assert_equal(3, table_rows.size)

      # let's choose the hidden file just to be sure we can choose them too.
      find('span', text: '.hidden_file').click
      find("##{base_id}_path_selector_button").click

      text_field = find("##{base_id}")
      assert_equal("#{dir}/app/.hidden_file", text_field.value)
    end
  end

  test 'path_selector can hide files, only showing directories' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - path
        attributes:
          path:
            widget: 'path_selector'
            directory: "#{Rails.root}"
            show_files: false
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      base_id = 'batch_connect_session_context_path'

      visit new_batch_connect_session_context_url('sys/app')
      click_on('Select Path')
      sleep 1

      # assert that all the rows in the table are real.
      # It should only be showing the directories in Rails.root (no files).
      find("##{base_id}_path_selector_table").all('tbody tr') do |table_row|
        table_datas = table_row.all('td')
        row_text = table_datas[1].find('span').text
        real_dir = Pathname.new(Rails.root).join(row_text)
        assert(real_dir.exist?)
        assert(real_dir.directory?)
      end

      find('span', text: 'test').click
      find("##{base_id}_path_selector_button").click

      text_field = find("##{base_id}")
      assert_equal("#{Rails.root}/test", text_field.value)
    end
  end

  test 'path_selector hides hidden files but not hidden directories' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - path
        attributes:
          path:
            widget: 'path_selector'
            directory: "#{dir}/app"
            show_hidden: true
            show_files: false
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      `mkdir -p #{dir}/app/.hidden_dir`
      `mkdir -p #{dir}/app/other_dir`
      `touch #{dir}/app/.hidden_file`
      base_id = 'batch_connect_session_context_path'

      visit new_batch_connect_session_context_url('sys/app')
      click_on('Select Path')
      sleep 1

      table_rows = find("##{base_id}_path_selector_table").all('tbody tr') do |table_row|
        table_datas = table_row.all('td')
        row_text = table_datas[1].find('span').text
        real_dir = Pathname.new("#{dir}/app").join(row_text)
        assert(real_dir.exist?)
        assert(real_dir.directory?)
      end

      # 4 things exist in the directory - but only the 2 directories are shown
      # the other 2 are form.yml and .hidden_file
      assert_equal(4, Dir.children("#{dir}/app").size, Dir.children("#{dir}/app").inspect)
      assert_equal(2, table_rows.size)

      # and we can select the hidden directory just for good measure.
      find('span', text: '.hidden_dir').click
      find("##{base_id}_path_selector_button").click

      text_field = find("##{base_id}")
      assert_equal("#{dir}/app/.hidden_dir", text_field.value)
    end
  end

  # test for bug https://github.com/OSC/ondemand/issues/3246
  test 'path selector can reselect files' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - path
        attributes:
          path:
            widget: 'path_selector'
            directory: "#{Rails.root}"
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      base_id = 'batch_connect_session_context_path'

      visit new_batch_connect_session_context_url('sys/app')
      click_on('Select Path')

      gem = find('span', exact_text: 'Gemfile')
      gem_lock = find('span', exact_text: 'Gemfile.lock')

      gem.click
      gem_lock.click
      gem.click

      find("##{base_id}_path_selector_button").click
      text_field = find("##{base_id}")
      assert_equal("#{Rails.root}/Gemfile", text_field.value)
    end
  end

  test 'path selector can relabel' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - path
        attributes:
          path:
            widget: 'path_selector'
            help: 'select a path using the button below'
            label: 'working directory'
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      visit new_batch_connect_session_context_url('sys/app')

      base_id = 'batch_connect_session_context_path'
      input = find("##{base_id}")

      # got the new label
      label = find("label[for='#{base_id}']")
      assert_equal('working directory', label.text)

      # the input has help text sibling with correct text
      help = input.sibling('small[class="form-text text-muted"]')
      assert_equal('select a path using the button below', help.text)
    end
  end

  test 'path selector displays favorites' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      OodFilesApp.stubs(:candidate_favorite_paths).returns([
                                                             FavoritePath.new('/tmp'),
                                                             FavoritePath.new('/var')
                                                           ])
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - path
        attributes:
          path:
            widget: 'path_selector'
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      visit new_batch_connect_session_context_url('sys/app')

      click_on('Select Path')

      # shows the OodFilesApp.candidate_favorite_paths favorites
      sleep 3
      favorites = get_favorites
      assert_equal(2, favorites.size)
      assert_equal('/tmp', favorites[0].text.strip)
      assert_equal('/var', favorites[1].text.strip)
    end
  end

  test 'path selector can choose new favorites' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - path
        attributes:
          path:
            widget: 'path_selector'
            favorites:
              - '/fs/ess'
              - '/fs/scratch'
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      visit new_batch_connect_session_context_url('sys/app')

      click_on('Select Path')

      # favorites that have been configured in yml
      sleep 3
      favorites = get_favorites
      assert_equal(2, favorites.size)
      assert_equal('/fs/ess', favorites[0].text.strip)
      assert_equal('/fs/scratch', favorites[1].text.strip)
    end
  end

  test 'path selector can disable favorites' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      OodFilesApp.stubs(:candidate_favorite_paths).returns([
                                                             FavoritePath.new('/tmp'),
                                                             FavoritePath.new('/var')
                                                           ])
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - path
        attributes:
          path:
            widget: 'path_selector'
            favorites: false
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      visit new_batch_connect_session_context_url('sys/app')

      click_on('Select Path')

      # no favorites show up
      sleep 3
      favorites = get_favorites
      assert_equal(0, favorites.size)
    end
  end

  def get_favorites
    # For debugging flaky tests
    all('#favorites li', wait: 30)
    # puts "FAVORITES: "
    # puts favorites.map{|i| i['innerHTML']}.join('')
  end

  test 'launches and saves settings as a template' do
    with_modified_env({ ENABLE_NATIVE_VNC: 'true', OOD_BC_SAVED_SETTINGS: 'true' }) do
      Dir.mktmpdir do |dir|
        stub_good_launch(dir)

        visit new_batch_connect_session_context_url('sys/bc_paraview')

        fill_in(bc_ele_id('bc_num_hours'), with: 5)
        fill_in(bc_ele_id('bc_account'), with: 'abc123')
        fill_in('bc_vnc_resolution_x_field', with: '500')
        fill_in('bc_vnc_resolution_y_field', with: '600')

        check('batch_connect_session_save_template')
        fill_in('modal_input_template_new_name', with: 'test template')
        sleep 5 # modal needs to sleep?
        click_on('Save')

        click_on('Launch', wait: 30)
        sleep 3
        expected = output_fixture('user_settings/simple_bc_test.yml')
        actual = File.read("#{dir}/settings.yml")

        assert_equal(expected, actual)
      end
    end
  end

  test 'saves settings as a template' do
    with_modified_env({ ENABLE_NATIVE_VNC: 'true', OOD_BC_SAVED_SETTINGS: 'true' }) do
      Dir.mktmpdir do |dir|
        Configuration.stubs(:user_settings_file).returns(Pathname.new("#{dir}/settings.yml"))
        BatchConnect::Session.any_instance.expects(:save).never
        OodCore::Job::Adapters::Slurm.any_instance.expects(:info).never

        visit new_batch_connect_session_context_url('sys/bc_paraview')

        fill_in(bc_ele_id('bc_num_hours'), with: 5)
        fill_in(bc_ele_id('bc_account'), with: 'abc123')
        fill_in('bc_vnc_resolution_x_field', with: '500')
        fill_in('bc_vnc_resolution_y_field', with: '600')

        check('batch_connect_session_save_template')
        fill_in('modal_input_template_new_name', with: 'test template')
        sleep 2 # modal needs to sleep?
        click_on('Save')

        click_on('Save settings and close', wait: 30)
        sleep 2
        expected = output_fixture('user_settings/simple_bc_test.yml')
        actual = File.read("#{dir}/settings.yml")

        assert_equal(expected, actual)
      end
    end
  end

  test 'date_fields correctly initialize when empty' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - date
        attributes:
          date:
            widget: 'date_field'
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      visit new_batch_connect_session_context_url('sys/app')

      value = find('#batch_connect_session_context_date').value
      assert_equal(Date.today.to_s, value)
    end
  end

  # Using attributes like 'filter' gets confused with Enumerable api
  # by the same name. So this test ensures things like that get serialized correctly.
  # see https://github.com/OSC/ondemand/issues/3604
  test 'filter is cached correctly' do
    Dir.mktmpdir do |dir|
      # output_dir = Pathname.new("#{dir}/output").tap { |p| FileUtils.mkdir_p(p.to_s) }
      cache_file = Pathname.new("#{dir}/cache_file.json")

      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      BatchConnect::Session.any_instance.stubs(:save).returns(true)
      BatchConnect::Session.any_instance.stubs(:job_id).returns('job-id-123')
      # BatchConnect::Session.any_instance.stubs(:staged_root).returns(output_dir)
      BatchConnect::SessionContextsController.any_instance.stubs(:cache_file).returns(cache_file)
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - filter
        attributes:
          filter:
            widget: select
            options:
            - ["A"]
            - ["B"]
      HEREDOC

      Pathname.new("#{dir}/app/").tap { |p| FileUtils.mkdir_p(p) }.join('form.yml').write(form)
      visit(new_batch_connect_session_context_url('sys/app'))
      id = bc_ele_id('filter')
      value = find("##{id}").value
      assert_equal('A', value)

      click_on('Launch')
      visit(new_batch_connect_session_context_url('sys/app'))
      cache_data = YAML.safe_load(File.read(cache_file.to_s)).to_h
      assert_equal('A', value)
      assert_equal({ 'cluster' => 'owens', 'filter' => 'A' }, cache_data)
    end
  end

  test 'password fields are encrypted in the cache.json' do
    Dir.mktmpdir do |dir|
      stub_good_launch(dir)
      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - some_field
          - some_password_field
        attributes:
          some_password_field:
            widget: 'password_field'
      HEREDOC

      make_bc_app(dir, form)
      visit new_batch_connect_session_context_url('sys/app')

      # they're empty to begin with
      assert(find("##{bc_ele_id('some_field')}").value.empty?)
      assert(find("##{bc_ele_id('some_password_field')}").value.empty?)

      # fill in some values and submit to get the cache file to write.
      raw_password = 'abc123'
      fill_in(bc_ele_id('some_field'), with: 42)
      fill_in(bc_ele_id('some_password_field'), with: raw_password)
      click_on('Launch')

      sleep 3
      visit new_batch_connect_session_context_url('sys/app')

      # the form has the previous values (password being plaintext).
      assert_equal('42', find("##{bc_ele_id('some_field')}").value)
      assert_equal(raw_password, find("##{bc_ele_id('some_password_field')}").value)

      cache_data = JSON.parse(File.read("#{dir}/sys_app.json"))

      # have to actually decrypt what was written as it's not deterministic.
      crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])
      stored_password = crypt.decrypt_and_verify(cache_data['some_password_field'])

      assert_equal(cache_data['some_field'], '42')
      assert_equal(cache_data['cluster'], 'owens')
      assert_equal(raw_password, stored_password)
    end
  end
end
