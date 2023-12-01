# frozen_string_literal: true

require 'application_system_test_case'

# Tests /projects URL and the associated code paths
class ProjectsTest < ApplicationSystemTestCase
  def setup
    stub_clusters
    stub_user
    stub_sacctmgr
    stub_scontrol

    # Stub Time.now for created_at field
    @expected_now = 1_679_943_564
    Time.stubs(:now).returns(Time.at(@expected_now))
  end

  def setup_project(root_dir, override_project_dir = nil)
    OodAppkit.stubs(:dataroot).returns(Pathname.new(root_dir))

    proj = 'test-project'
    desc = 'test-description'
    icon = 'fas://arrow-right'
    visit projects_path
    click_on I18n.t('dashboard.jobs_create_blank_project')
    find('#project_name').set(proj)
    find('#project_directory').set(override_project_dir) if override_project_dir
    find('#project_description').set(desc)
    find('#product_icon_select').set(icon)
    click_on 'Save'

    project_element = find('.project-card')
    project_id = project_element[:id]

    project_dir = override_project_dir || "#{root_dir}/projects/#{project_id}"
    `echo 'some_other_command' > #{project_dir}/my_cool_script.sh`
    `echo 'hostname' > #{project_dir}/my_cooler_script.bash`

    project_id
  end

  def setup_script(project_id)
    visit project_path(project_id)
    click_on 'New Script'
    find('#script_title').set('the script title')
    click_on 'Save'

    script_element = find('.script-card')
    script_element[:id]
  end

  def add_account(project_id, script_id)
    visit project_path(project_id)
    edit_script_path = edit_project_script_path(project_id, script_id)
    find("[href='#{edit_script_path}']").click

    # now add 'auto_accounts'
    click_on('Add new option')
    select('Account', from: 'add_new_field_select')
    click_on(I18n.t('dashboard.add'))
    click_on(I18n.t('dashboard.save'))
  end

  def add_bc_num_hours(project_id, script_id)
    visit project_path(project_id)
    edit_script_path = edit_project_script_path(project_id, script_id)
    find("[href='#{edit_script_path}']").click

    # now add 'bc_num_hours'
    click_on('Add new option')
    select('Hours', from: 'add_new_field_select')
    click_on(I18n.t('dashboard.add'))
    fill_in('script_bc_num_hours', with: 1)
    click_on(I18n.t('dashboard.save'))
  end

  test 'create a new project on fs and display the table entry' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)

      assert_selector '.alert-success', text: 'Project successfully created!'
      assert_selector "[href='/projects/#{project_id}']", text: 'Test Project'
      assert File.directory? File.join("#{dir}/projects", project_id)
    end
  end

  test 'creates .ondemand directory with project' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)

      assert File.directory? File.join("#{dir}/projects", project_id, '.ondemand')
    end
  end

  test 'creates project overriding project location' do
    Dir.mktmpdir do |dir|
      project_override_dir = File.join(dir, 'dir_override')
      Pathname(project_override_dir).mkpath
      setup_project(dir, project_override_dir)

      assert File.directory?(File.join(project_override_dir.to_s, '.ondemand'))
      assert File.exist?(File.join(project_override_dir.to_s, '.ondemand', 'manifest.yml'))

      # Cleanup to avoid side effects
      accept_confirm do
        click_on 'Delete'
      end
      assert_selector '.alert-success', text: 'Project successfully deleted!'
    end
  end

  test 'delete a project from the fs and ensure no table entry' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      assert File.directory? File.join(dir, 'projects', project_id)

      accept_confirm do
        click_on 'Delete'
      end

      assert_selector '.alert-success', text: 'Project successfully deleted!'
      assert_no_selector "[href='/projects/#{project_id}']", text: 'Test Project'
      assert File.directory? File.join(dir, 'projects', project_id)
      assert_not File.directory? File.join(dir, 'projects', project_id, '.ondemand')
    end
  end

  test 'work in a project' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)

      find("[href='/projects/#{project_id}']").click
      assert_selector 'h1', text: 'Test Project'
      assert_selector '.btn.btn-default', text: 'Back'
    end
  end

  test 'edit a project' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)

      click_on 'Edit'
      find('#project_name').set('my-test-project')
      click_on 'Save'
      assert_selector "[href='/projects/#{project_id}']", text: 'My Test Project'
      click_on 'Edit'
      assert_selector 'h1', text: 'Editing: My Test Project'
      assert_equal 'my-test-project', find('#project_name').value
      assert_equal "#{dir}/projects/#{project_id}", find('#project_directory').value
      assert_equal 'test-description', find('#project_description').value
      assert_equal 'fas://arrow-right', find('#product_icon_select').value
      assert_selector '.btn.btn-default', text: 'Back'
    end
  end

  test 'create with invalid icon triggers alert' do
    Dir.mktmpdir do |dir|
      OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))
      proj = 'test-project'
      icon = 'fas://bad&icon8'
      visit projects_path
      click_on I18n.t('dashboard.jobs_create_blank_project')
      find('#project_name').set(proj)
      find('#product_icon_select').set(icon)
      click_on 'Save'

      assert_selector '.alert-danger', text: I18n.t('dashboard.jobs_project_validation_error')
    end
  end

  test 'update with invalid icon' do
    Dir.mktmpdir do |dir|
      setup_project(dir)
      click_on 'Edit'
      find('#product_icon_select').set('fas://bad&icon')
      click_on 'Save'

      assert_selector '.alert-danger', text: I18n.t('dashboard.jobs_project_validation_error')
    end
  end

  test 'creating and showing scripts' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      script_id = setup_script(project_id)

      expected_yml = <<~HEREDOC
        ---
        title: the script title
        created_at: #{@expected_now}
        form:
        - auto_batch_clusters
        - auto_scripts
        attributes:
          auto_batch_clusters:
            options:
            - oakley
            - owens
            label: Cluster
            help: ''
            required: false
          auto_scripts:
            options:
            - - my_cool_script.sh
              - "#{dir}/projects/#{project_id}/my_cool_script.sh"
            - - my_cooler_script.bash
              - "#{dir}/projects/#{project_id}/my_cooler_script.bash"
            directory: "#{dir}/projects/#{project_id}"
            label: Script
            help: ''
            required: false
      HEREDOC

      success_message = I18n.t('dashboard.jobs_scripts_created')
      assert_selector('.alert-success', text: "×\nClose\n#{success_message}")
      assert_equal(expected_yml, File.read("#{dir}/projects/#{project_id}/.ondemand/scripts/#{script_id}/form.yml"))

      script_path = project_script_path(project_id, script_id)
      find("[href='#{script_path}'].btn-success").click
      assert_selector('h1', text: 'the script title', count: 1)
    end
  end

  test 'showing scripts with auto attributes' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      script_id = setup_script(project_id)
      project_dir = File.join(dir, 'projects', project_id)
      add_account(project_id, script_id)

      script_path = project_script_path(project_id, script_id)
      find("[href='#{script_path}'].btn-success").click
      assert_selector('h1', text: 'the script title', count: 1)

      expected_accounts = ['pas1604', 'pas1754', 'pas1871', 'pas2051', 'pde0006', 'pzs0714', 'pzs0715', 'pzs1010',
                           'pzs1117', 'pzs1118', 'pzs1124'].to_set

      assert_equal(expected_accounts, page.all('#script_auto_accounts option').map(&:value).to_set)
      assert_equal(["#{project_dir}/my_cool_script.sh", "#{project_dir}/my_cooler_script.bash"].to_set,
                   page.all('#script_auto_scripts option').map(&:value).to_set)

      # clusters are automatically added
      assert_equal(['owens', 'oakley'].to_set, page.all('#script_auto_batch_clusters option').map(&:value).to_set)
    end
  end

  test 'deleting a script that succeeds' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      script_id = setup_script(project_id)
      project_dir = File.join(dir, 'projects', project_id)
      script_dir = File.join(project_dir, '.ondemand', 'scripts', script_id)

      # ASSERT SCRIPT DIRECTORY IS CREATED
      assert_equal true, File.directory?(script_dir)

      expected_script_files = ["#{script_dir}/form.yml", "#{script_dir}/job_history.log"]
      # ASSERT EXPECTED SCRIPT FILES
      expected_script_files.each do |file_path|
        assert_equal true, File.exist?(file_path)
      end

      accept_confirm do
        click_on 'Delete'
      end

      assert_selector '.alert-success', text: 'Script successfully deleted!'
      # ASSERT SCRIPT DIRECTORY IS DELETED
      assert_not File.directory? script_dir
    end
  end

  test 'submitting a script with auto attributes that succeeds' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      script_id = setup_script(project_id)
      project_dir = File.join(dir, 'projects', project_id)
      script_dir = File.join(project_dir, '.ondemand', 'scripts', script_id)
      add_account(project_id, script_id)

      script_path = project_script_path(project_id, script_id)
      find("[href='#{script_path}'].btn-success").click
      assert_selector('h1', text: 'the script title', count: 1)

      # assert defaults
      assert_equal 'oakley', find('#script_auto_batch_clusters').value
      assert_equal 'pzs0715', find('#script_auto_accounts').value
      assert_equal "#{project_dir}/my_cool_script.sh", find('#script_auto_scripts').value
      assert_nil YAML.safe_load(File.read("#{script_dir}/job_history.log"))

      select('owens', from: 'script_auto_batch_clusters')
      select('pas2051', from: 'script_auto_accounts')
      select('my_cooler_script.bash', from: 'script_auto_scripts')

      Open3
        .stubs(:capture3)
        .with({}, 'sbatch', '-A', 'pas2051', '--export', 'NONE', '--parsable', '-M', 'owens',
              stdin_data: "hostname\n")
        .returns(['job-id-123', '', exit_success])

      OodCore::Job::Adapters::Slurm.any_instance
                                   .stubs(:info).returns(OodCore::Job::Info.new(id: 'job-id-123', status: :running))

      click_on 'Launch'
      assert_selector('.alert-success', text: 'job-id-123')
      assert_equal [{ 'id'          => 'job-id-123',
                      'submit_time' => @expected_now,
                      'cluster'     => 'owens' }],
                   YAML.safe_load(File.read("#{script_dir}/job_history.log"))
    end
  end

  test 'submitting a script with auto attributes that fails' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      script_id = setup_script(project_id)
      project_dir = File.join(dir, 'projects', project_id)
      script_dir = File.join(project_dir, '.ondemand', 'scripts', script_id)
      add_account(project_id, script_id)

      script_path = project_script_path(project_id, script_id)
      find("[href='#{script_path}'].btn-success").click
      assert_selector('h1', text: 'the script title', count: 1)

      # assert defaults
      assert_equal 'oakley', find('#script_auto_batch_clusters').value
      assert_equal 'pzs0715', find('#script_auto_accounts').value
      assert_equal "#{project_dir}/my_cool_script.sh", find('#script_auto_scripts').value
      assert_nil YAML.safe_load(File.read("#{script_dir}/job_history.log"))

      select('owens', from: 'script_auto_batch_clusters')
      select('pas2051', from: 'script_auto_accounts')
      select('my_cooler_script.bash', from: 'script_auto_scripts')

      Open3
        .stubs(:capture3)
        .with({}, 'sbatch', '-A', 'pas2051', '--export', 'NONE', '--parsable', '-M', 'owens',
              stdin_data: "hostname\n")
        .returns(['', 'some error message', exit_failure])

      click_on 'Launch'
      assert_selector('.alert-danger', text: "×\nClose\nsome error message")
      assert_nil YAML.safe_load(File.read("#{script_dir}/job_history.log"))
    end
  end

  test 'editing scripts initializes correctly' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      script_id = setup_script(project_id)

      visit project_path(project_id)

      edit_script_path = edit_project_script_path(project_id, script_id)
      find("[href='#{edit_script_path}']").click

      click_on('Add new option')
      new_field_id = 'add_new_field_select'

      actual_new_options = page.all("##{new_field_id} option").map(&:value).to_set
      expected_new_options = ['bc_num_hours', 'auto_queues', 'bc_num_slots', 'auto_accounts'].to_set
      assert_equal expected_new_options, actual_new_options
    end
  end

  test 'adding new fields to scripts' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      script_id = setup_script(project_id)

      visit project_path(project_id)

      edit_script_path = edit_project_script_path(project_id, script_id)
      find("[href='#{edit_script_path}']").click

      # only shows 'cluster' & 'auto_scripts'
      assert_equal 2, page.all('.form-group').size
      assert_not_nil find('#script_auto_batch_clusters')
      assert_not_nil find('#script_auto_scripts')
      select('oakley', from: 'script_auto_batch_clusters')
      assert_raises(Capybara::ElementNotFound) do
        find('#script_bc_num_hours')
      end

      # add bc_num_hours
      add_bc_num_hours(project_id, script_id)
      script_edit_path = edit_project_script_path(project_id, script_id)
      find("[href='#{script_edit_path}']").click

      # now shows 'cluster', 'auto_scripts' & the newly added'bc_num_hours'
      assert_equal 3, page.all('.form-group').size
      assert_not_nil find('#script_auto_batch_clusters')
      assert_not_nil find('#script_auto_scripts')
      assert_not_nil find('#script_bc_num_hours')

      # edit default, min & max
      find('#edit_script_bc_num_hours').click
      fill_in('script_bc_num_hours', with: 42)
      fill_in('script_bc_num_hours_min', with: 20)
      fill_in('script_bc_num_hours_max', with: 101)
      find('#script_bc_num_hours_fixed').click
      find('#save_script_bc_num_hours').click

      # correctly saves
      click_on(I18n.t('dashboard.save'))
      success_message = I18n.t('dashboard.jobs_scripts_updated')
      assert_selector('.alert-success', text: "×\nClose\n#{success_message}")
      assert_current_path project_path(project_id)

      # note that bc_num_hours has default, min & max
      expected_yml = <<~HEREDOC
        ---
        title: the script title
        created_at: #{@expected_now}
        form:
        - auto_scripts
        - auto_batch_clusters
        - bc_num_hours
        attributes:
          auto_scripts:
            options:
            - - my_cool_script.sh
              - "#{dir}/projects/#{project_id}/my_cool_script.sh"
            - - my_cooler_script.bash
              - "#{dir}/projects/#{project_id}/my_cooler_script.bash"
            directory: "#{dir}/projects/#{project_id}"
            value: "#{dir}/projects/#{project_id}/my_cool_script.sh"
            label: Script
            help: ''
            required: false
          auto_batch_clusters:
            options:
            - oakley
            - owens
            value: oakley
            label: Cluster
            help: ''
            required: false
          bc_num_hours:
            min: 20
            step: 1
            value: '42'
            fixed: true
            max: 101
            label: Number of hours
            help: ''
            required: true
      HEREDOC

      assert_equal(expected_yml, File.read("#{dir}/projects/#{project_id}/.ondemand/scripts/#{script_id}/form.yml"))
    end
  end

  test 'removing script fields' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      script_id = setup_script(project_id)

      # add bc_num_hours
      add_bc_num_hours(project_id, script_id)
      add_account(project_id, script_id)

      # go to edit it and see that there is cluster and bc_num_hours
      visit project_path(project_id)
      edit_script_path = edit_project_script_path(project_id, script_id)
      find("[href='#{edit_script_path}']").click
      # puts page.body
      assert_equal 4, page.all('.form-group').size
      assert_not_nil find('#script_auto_batch_clusters')
      assert_not_nil find('#script_auto_scripts')
      assert_not_nil find('#script_bc_num_hours')
      assert_not_nil find('#script_auto_accounts')
      select('oakley', from: 'script_auto_batch_clusters')

      # remove bc num hours and it's not in the form
      find('#remove_script_bc_num_hours').click
      assert_equal 3, page.all('.form-group').size
      assert_not_nil find('#script_auto_batch_clusters')
      assert_not_nil find('#script_auto_scripts')
      assert_not_nil find('#script_auto_accounts')
      assert_raises(Capybara::ElementNotFound) do
        find('#script_bc_num_hours')
      end

      # correctly saves
      click_on(I18n.t('dashboard.save'))
      success_message = I18n.t('dashboard.jobs_scripts_updated')
      assert_selector('.alert-success', text: "×\nClose\n#{success_message}")
      assert_current_path project_path(project_id)

      expected_yml = <<~HEREDOC
        ---
        title: the script title
        created_at: #{@expected_now}
        form:
        - auto_accounts
        - auto_scripts
        - auto_batch_clusters
        attributes:
          auto_accounts:
            options:
            - pzs0715
            - pzs0714
            - pzs1124
            - pzs1118
            - pzs1117
            - pzs1010
            - pde0006
            - pas2051
            - pas1871
            - pas1754
            - pas1604
            value: pzs0715
            label: Account
            help: ''
            required: false
          auto_scripts:
            options:
            - - my_cool_script.sh
              - "#{dir}/projects/#{project_id}/my_cool_script.sh"
            - - my_cooler_script.bash
              - "#{dir}/projects/#{project_id}/my_cooler_script.bash"
            directory: "#{dir}/projects/#{project_id}"
            value: "#{dir}/projects/#{project_id}/my_cool_script.sh"
            label: Script
            help: ''
            required: false
          auto_batch_clusters:
            options:
            - oakley
            - owens
            value: oakley
            label: Cluster
            help: ''
            required: false
      HEREDOC

      assert_equal(expected_yml, File.read("#{dir}/projects/#{project_id}/.ondemand/scripts/#{script_id}/form.yml"))
    end
  end

  test 'cant show invalid project' do
    visit project_path('1')
    assert_current_path('/projects')
    assert_selector('.alert-danger', text: 'Cannot find project 1')
  end

  test 'cant edit invalid project' do
    visit edit_project_path('1')
    assert_current_path('/projects')
    assert_selector('.alert-danger', text: 'Cannot find project 1')
  end

  test 'cant create script when project is invalid' do
    visit edit_project_script_path('1', '1')
    assert_current_path('/projects')
    assert_selector('.alert-danger', text: "×\nClose\nCannot find project: 1")
  end

  test 'cant show script when project is invalid' do
    visit project_script_path('1', '1')
    assert_current_path('/projects')
    assert_selector('.alert-danger', text: "×\nClose\nCannot find project: 1")
  end

  test 'cant edit script when project is invalid' do
    visit edit_project_script_path('1', '1')
    assert_current_path('/projects')
    assert_selector('.alert-danger', text: "×\nClose\nCannot find project: 1")
  end

  test 'cant show invalid script' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      visit project_script_path(project_id, '1')
      assert_current_path("/projects/#{project_id}")
      assert_selector('.alert-danger', text: "×\nClose\nCannot find script 1")
    end
  end

  test 'cant edit invalid script' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      visit edit_project_script_path(project_id, '1')
      assert_current_path("/projects/#{project_id}")
      assert_selector('.alert-danger', text: "×\nClose\nCannot find script 1")
    end
  end

  # this test:
  # creates a project & script with auto_accounts
  # excludes some of the accounts from auto_accounts in script#edit
  # asserts that they've actually been removed from script#show
  # adds some of the accounts back in script#edit
  # asserts that the _new_ list of excluded accounts have actually been removed from script#show
  test 'excluding and including select options' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      script_id = setup_script(project_id)
      add_account(project_id, script_id)

      visit edit_project_script_path(project_id, script_id)

      find('#edit_script_auto_accounts').click
      exclude_accounts = ['pas2051', 'pas1871', 'pas1754', 'pas1604']
      exclude_accounts.each do |acct|
        rm_btn = find("#script_auto_accounts_remove_#{acct}")
        add_btn = find("#script_auto_accounts_add_#{acct}")

        # rm is enabled and add is disabled.
        assert_equal('false', rm_btn[:disabled])
        assert_equal('true', add_btn[:disabled])
        rm_btn.click

        # after clicking, they toggle
        assert_equal('true', rm_btn[:disabled])
        assert_equal('false', add_btn[:disabled])
      end

      find('#save_script_edit').click
      assert_current_path(project_path(project_id))
      script_path = project_script_path(project_id, script_id)
      find("[href='#{script_path}'].btn-success").click

      # now let's check scripts#show to see if they've actually been excluded.
      show_account_options = page.all('#script_auto_accounts option').map(&:value)
      exclude_accounts.each do |acct|
        assert(!show_account_options.include?(acct))
      end

      visit edit_project_script_path(project_id, script_id)
      find('#edit_script_auto_accounts').click

      exclude_accounts.each do |acct|
        rm_btn = find("#script_auto_accounts_remove_#{acct}")
        add_btn = find("#script_auto_accounts_add_#{acct}")

        # now add is enabled and rm is disabled. (opposite of the above)
        assert_equal('false', add_btn[:disabled])
        assert_equal('true', rm_btn[:disabled])
        add_btn.click

        # after clicking, they toggle
        assert_equal('true', add_btn[:disabled])
        assert_equal('false', rm_btn[:disabled])
      end

      find('#save_script_edit').click
      assert_current_path(project_path(project_id))
      script_path = project_script_path(project_id, script_id)
      find("[href='#{script_path}'].btn-success").click

      # now let's check scripts#show and they should be back.
      show_account_options = page.all('#script_auto_accounts option').map(&:value)
      exclude_accounts.each do |acct|
        assert(show_account_options.include?(acct))
      end
    end
  end

  test 'fixing select options' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      script_id = setup_script(project_id)
      add_account(project_id, script_id)

      visit edit_project_script_path(project_id, script_id)

      find('#edit_script_auto_accounts').click
      accounts_select = find('#script_auto_accounts')
      account_options = accounts_select.all('option')
      find("#script_auto_accounts_fixed").click

      # Validate that UI changes when field is fixed.
      assert_equal('true', accounts_select[:disabled])
      account_options.each do |option|
        rm_btn = find("#script_auto_accounts_remove_#{option.text}")
        add_btn = find("#script_auto_accounts_add_#{option.text}")

        option_text_strike = option.selected? ? 0 : 1
        assert_selector("li.text-strike > button#script_auto_accounts_add_#{option.text}", count: option_text_strike)
        assert_equal(true, option.disabled?)
        assert_equal('true', add_btn[:disabled])
        assert_equal('true', rm_btn[:disabled])
      end
    end
  end

  # this test is similar to the one above, only it captures
  # the case when you've added the field, but haven't saved
  # it yet. See https://github.com/OSC/ondemand/issues/3017
  test 'excluding newly created options' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      script_id = setup_script(project_id)
      visit(edit_project_script_path(project_id, script_id))

      # now add 'auto_accounts'
      click_on('Add new option')
      select('Account', from: 'add_new_field_select')
      click_on(I18n.t('dashboard.add'))
      find('#edit_script_auto_accounts').click

      ['pas2051', 'pas1871', 'pas1754', 'pas1604'].each do |acct|
        rm_btn = find("#script_auto_accounts_remove_#{acct}")
        add_btn = find("#script_auto_accounts_add_#{acct}")

        # rm is enabled and add is disabled.
        assert_equal('false', rm_btn[:disabled])
        assert_equal('true', add_btn[:disabled])
        rm_btn.click

        # after clicking, they toggle
        assert_equal('true', rm_btn[:disabled])
        assert_equal('false', add_btn[:disabled])
      end
    end
  end

  test 'creating project from template updates forms' do
    Dir.mktmpdir do |dir|
      Project.stubs(:dataroot).returns(Pathname.new(dir))
      Configuration.stubs(:project_template_dir).returns("#{Rails.root}/test/fixtures/projects")

      visit(projects_root_path)
      click_on(I18n.t('dashboard.jobs_create_template_project'))

      select('Chemistry 5533', from: 'project_template')

      # nothing in the users' project directory yet.
      assert_equal(['.project_lookup'], Dir.children(dir))
      assert_equal('', File.read("#{dir}/.project_lookup"))

      click_on(I18n.t('dashboard.save'))

      assert_equal(2, Dir.children(dir).size)
      project_dir = Dir.children(dir).select { |path| File.directory?("#{dir}/#{path}") }.first
      abs_project_dir = "#{dir}/#{project_dir}"

      # 3 shell scripts, 3 forms were copied
      assert_equal(3, Dir.glob("#{abs_project_dir}/*.sh").size)
      forms = Dir.glob("#{abs_project_dir}/.ondemand/**/*/form.yml")
      assert_equal(3, forms.size)

      orig_form = "#{Rails.root}/test/fixtures/projects/chemistry-5533/.ondemand/scripts/8woi7ghd/form.yml"
      orig_form = YAML.safe_load(File.read(orig_form))

      new_form = YAML.safe_load(File.read(forms.first))

      # 'form' & 'title' are the same
      assert_equal(orig_form['form'], new_form['form'])
      assert_equal(orig_form['title'], new_form['title'])

      # every auto_scripts option was copied and has the _new_ project location.
      new_auto_scripts = new_form['attributes']['auto_scripts']['options']
      new_auto_scripts.each_with_index do |option, idx|
        filename = "assignment_#{idx + 1}.sh"
        full_path = "#{abs_project_dir}/#{filename}"
        assert_equal(filename, option[0])
        assert_equal(full_path, option[1])
      end
    end
  end
end
