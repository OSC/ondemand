# frozen_string_literal: true

require 'application_system_test_case'

# Tests /projects URL and the associated code paths
class ProjectManagerTest < ApplicationSystemTestCase
  def setup
    stub_clusters
    stub_user
    stub_sacctmgr
    stub_scontrol
    stub_du
    stub_sinfo

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

  def setup_launcher(project_id)
    visit project_path(project_id)
    click_on 'New Launcher'
    find('#launcher_title').set('the launcher title')
    click_on 'Save'

    launcher_element = all('#launcher_list div.list-group-item').first
    launcher_element[:id].gsub('launcher_', '')
  end

  def add_account(project_id, launcher_id, save: true)
    visit project_path(project_id)
    edit_launcher_path = edit_project_launcher_path(project_id, launcher_id)
    find("[href='#{edit_launcher_path}']").click

    # now add 'auto_accounts'
    click_on('Add new option')
    select('Account', from: 'add_new_field_select')
    click_on(I18n.t('dashboard.add'))
    click_on(I18n.t('dashboard.save')) if save
  end

  def add_bc_num_hours(project_id, launcher_id)
    visit project_path(project_id)
    edit_launcher_path = edit_project_launcher_path(project_id, launcher_id)
    find("[href='#{edit_launcher_path}']").click

    # now add 'bc_num_hours'
    click_on('Add new option')
    select('Hours', from: 'add_new_field_select')
    click_on(I18n.t('dashboard.add'))
    fill_in('launcher_bc_num_hours', with: 1)
    click_on(I18n.t('dashboard.save'))
  end

  def add_auto_environment_variable(project_id, launcher_id, save: true)
    # now add 'auto_environment_variable'
    click_on('Add new option')
    select('Environment Variable', from: 'add_new_field_select')
    click_on(I18n.t('dashboard.add'))
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

  test 'project show should support JSON' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)

      visit project_path(project_id, format: :json)
      json_response = find('body').text
      project_data = JSON.parse(json_response, symbolize_names: true)
      assert_equal project_id, project_data[:id]
      assert_equal 'test-project', project_data[:name]
      assert_equal 'test-description', project_data[:description]
      assert_equal 'fas://arrow-right', project_data[:icon]
      assert_equal "#{dir}/projects/#{project_id}", project_data[:directory]
      assert_equal 2097152, project_data[:size]
      assert_equal '2 MB', project_data[:human_size]
    end
  end

  test 'edit a project' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)

      click_on 'Edit'
      find('#project_name').set('my-test-project', clear: :backspace)
      click_on 'Save'
      assert_selector "[href='/projects/#{project_id}']", text: 'My Test Project'
      click_on 'Edit'
      assert_selector 'h1', text: 'Editing: My Test Project'
      assert_equal 'my-test-project', find('#project_name').value
      assert_equal "#{dir}/projects/#{project_id}", find('#project_directory').value
      assert_equal 'test-description', find('#project_description').value
      assert_equal 'arrow-right', find('#product_icon_select').value
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

  test 'all icons show initially' do
    visit(new_project_path)
    icons = find('#icon_picker_list').all('i')
    assert_equal(990, icons.size)
  end

  test 'searching icons works' do
    visit(new_project_path)
    find('#product_icon_select').set('')
    find('#product_icon_select').set('cog')
    icons = find('#icon_picker_list').all('i')
    assert_equal(4, icons.size)
  end

  test 'all icons show after clearing input field' do
    visit(new_project_path)
    find('#product_icon_select').set('')
    icons = find('#icon_picker_list').all('i')
    assert_equal(990, icons.size)
  end

  test 'creating and showing launchers' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      launcher_id = setup_launcher(project_id)

      expected_yml = <<~HEREDOC
        ---
        title: the launcher title
        created_at: #{@expected_now}
        form:
        - auto_batch_clusters
        - auto_scripts
        attributes:
          auto_batch_clusters:
            options:
            - - oakley
              - oakley
              - data-max-auto-cores: 80
            - - owens
              - owens
              - data-max-auto-cores: 48
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

      success_message = I18n.t('dashboard.jobs_launchers_created')
      assert_selector('.alert-success', text: "Close\n#{success_message}")
      assert_equal(expected_yml, File.read("#{dir}/projects/#{project_id}/.ondemand/launchers/#{launcher_id}/form.yml"))

      launcher_path = project_launcher_path(project_id, launcher_id)
      find("[href='#{launcher_path}'].btn-info").click
      assert_selector('h1', text: 'the launcher title', count: 1)
    end
  end

  test 'creates new laucher with default items' do
    Dir.mktmpdir do |dir|
      Configuration.stubs(:launcher_default_items).returns(['bc_num_hours'])
      project_id = setup_project(dir)
      launcher_id = setup_launcher(project_id)

      # note that bc_num_hours is in this YAML.
      expected_yml = <<~HEREDOC
        ---
        title: the launcher title
        created_at: #{@expected_now}
        form:
        - auto_batch_clusters
        - auto_scripts
        - bc_num_hours
        attributes:
          auto_batch_clusters:
            options:
            - - oakley
              - oakley
              - data-max-auto-cores: 80
            - - owens
              - owens
              - data-max-auto-cores: 48
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
          bc_num_hours:
            min: 1
            step: 1
            label: Number of hours
            help: ''
            required: true
      HEREDOC

      success_message = I18n.t('dashboard.jobs_launchers_created')
      assert_selector('.alert-success', text: "Close\n#{success_message}")
      assert_equal(expected_yml, File.read("#{dir}/projects/#{project_id}/.ondemand/launchers/#{launcher_id}/form.yml"))
    end
  end

  test 'showing launchers with auto attributes' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      launcher_id = setup_launcher(project_id)
      project_dir = File.join(dir, 'projects', project_id)
      add_account(project_id, launcher_id)

      launcher_path = project_launcher_path(project_id, launcher_id)
      find("[href='#{launcher_path}'].btn-info").click
      assert_selector('h1', text: 'the launcher title', count: 1)

      expected_accounts = ['pas1604', 'pas1754', 'pas1871', 'pas2051', 'pde0006', 'pzs0714', 'pzs0715', 'pzs1010',
                           'pzs1117', 'pzs1118', 'pzs1124'].to_set

      assert_equal(expected_accounts, page.all('#launcher_auto_accounts option').map(&:value).to_set)
      assert_equal(["#{project_dir}/my_cool_script.sh", "#{project_dir}/my_cooler_script.bash"].to_set,
                   page.all('#launcher_auto_scripts option').map(&:value).to_set)

      # clusters are automatically added
      assert_equal(['owens', 'oakley'].to_set, page.all('#launcher_auto_batch_clusters option').map(&:value).to_set)
    end
  end

  test 'deleting a launcher that succeeds' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      launcher_id = setup_launcher(project_id)
      project_dir = File.join(dir, 'projects', project_id)
      ondemand_dir = File.join(project_dir, '.ondemand')
      launcher_dir = File.join(ondemand_dir, 'launchers', launcher_id)

      # ASSERT SCRIPT DIRECTORY IS CREATED
      assert_equal true, File.directory?(launcher_dir)

      expected_script_files = ["#{launcher_dir}/form.yml", "#{ondemand_dir}/job_log.yml"]
      # ASSERT EXPECTED SCRIPT FILES
      expected_script_files.each do |file_path|
        assert_equal true, File.exist?(file_path), "#{file_path} does not exist"
      end

      accept_confirm do
        find("#delete_#{launcher_id}").click
      end

      assert_selector '.alert-success', text: 'Launcher successfully deleted!'
      # ASSERT SCRIPT DIRECTORY IS DELETED
      assert_not File.directory? launcher_dir
    end
  end

  test 'submitting a script with auto attributes that succeeds' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      launcher_id = setup_launcher(project_id)
      project_dir = File.join(dir, 'projects', project_id)
      ondemand_dir = File.join(project_dir, '.ondemand')
      add_account(project_id, launcher_id)

      launcher_path = project_launcher_path(project_id, launcher_id)
      find("[href='#{launcher_path}'].btn-info").click
      assert_selector('h1', text: 'the launcher title', count: 1)

      # assert defaults
      assert_equal 'oakley', find('#launcher_auto_batch_clusters').value
      assert_equal 'pzs0715', find('#launcher_auto_accounts').value
      assert_equal "#{project_dir}/my_cool_script.sh", find('#launcher_auto_scripts').value
      assert_nil YAML.safe_load(File.read("#{ondemand_dir}/job_log.yml"))

      select('owens', from: 'launcher_auto_batch_clusters')
      select('pas2051', from: 'launcher_auto_accounts')
      select('my_cooler_script.bash', from: 'launcher_auto_scripts')

      Open3
        .stubs(:capture3)
        .with({}, 'sbatch', '-D', project_dir, '-A', 'pas2051', '--export', 'NONE', '--parsable', '-M', 'owens',
              stdin_data: "hostname\n")
        .returns(['job-id-123', '', exit_success])

      OodCore::Job::Adapters::Slurm.any_instance
                                   .stubs(:info).returns(OodCore::Job::Info.new(id: 'job-id-123', status: :running))

      click_on 'Launch'
      assert_selector('.alert-success', text: 'job-id-123')
      jobs = YAML.safe_load(File.read("#{ondemand_dir}/job_log.yml"), permitted_classes: [Time])

      assert_equal(1, jobs.size)
      assert_equal('job-id-123', jobs[0]['id'])
    end
  end

  # super similar to test above, only it adds auto_job_name
  test 'submitting a script with job name' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      launcher_id = setup_launcher(project_id)
      project_dir = File.join(dir, 'projects', project_id)
      ondemand_dir = File.join(project_dir, '.ondemand')
      add_account(project_id, launcher_id, save: false)

      click_on('Add new option')
      select('Job Name', from: 'add_new_field_select')
      click_on(I18n.t('dashboard.add'))
      fill_in('launcher_auto_job_name', with: 'my cool job name')
      click_on(I18n.t('dashboard.save'))

      launcher_path = project_launcher_path(project_id, launcher_id)
      find("[href='#{launcher_path}'].btn-info").click
      assert_selector('h1', text: 'the launcher title', count: 1)

      # assert defaults
      assert_equal 'oakley', find('#launcher_auto_batch_clusters').value
      assert_equal 'pzs0715', find('#launcher_auto_accounts').value
      assert_equal "#{project_dir}/my_cool_script.sh", find('#launcher_auto_scripts').value
      assert_nil YAML.safe_load(File.read("#{ondemand_dir}/job_log.yml"))

      select('owens', from: 'launcher_auto_batch_clusters')
      select('pas2051', from: 'launcher_auto_accounts')
      select('my_cooler_script.bash', from: 'launcher_auto_scripts')

      Open3
        .stubs(:capture3)
        .with({}, 'sbatch', '-D', project_dir,
              '-J', 'project-manager/my cool job name', '-A', 'pas2051', '--export',
              'NONE', '--parsable', '-M', 'owens',
              stdin_data: "hostname\n")
        .returns(['job-id-123', '', exit_success])

      OodCore::Job::Adapters::Slurm.any_instance
                                   .stubs(:info).returns(OodCore::Job::Info.new(id: 'job-id-123', status: :running))

      click_on 'Launch'
      assert_selector('.alert-success', text: 'job-id-123')
      jobs = YAML.safe_load(File.read("#{ondemand_dir}/job_log.yml"), permitted_classes: [Time])

      assert_equal(1, jobs.size)
      assert_equal('job-id-123', jobs[0]['id'])
    end
  end

  test 'submitting a script with auto attributes that fails' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      launcher_id = setup_launcher(project_id)
      project_dir = File.join(dir, 'projects', project_id)
      ondemand_dir = File.join(project_dir, '.ondemand')
      add_account(project_id, launcher_id)

      launcher_path = project_launcher_path(project_id, launcher_id)
      find("[href='#{launcher_path}'].btn-info").click
      assert_selector('h1', text: 'the launcher title', count: 1)

      # assert defaults
      assert_equal 'oakley', find('#launcher_auto_batch_clusters').value
      assert_equal 'pzs0715', find('#launcher_auto_accounts').value
      assert_equal "#{project_dir}/my_cool_script.sh", find('#launcher_auto_scripts').value
      assert_nil YAML.safe_load(File.read("#{ondemand_dir}/job_log.yml"))

      select('owens', from: 'launcher_auto_batch_clusters')
      select('pas2051', from: 'launcher_auto_accounts')
      select('my_cooler_script.bash', from: 'launcher_auto_scripts')

      Open3
        .stubs(:capture3)
        .with({}, 'sbatch', '-D', project_dir, '-A', 'pas2051', '--export', 'NONE', '--parsable', '-M', 'owens',
              stdin_data: "hostname\n")
        .returns(['', 'some error message', exit_failure])

      click_on 'Launch'
      assert_selector('.alert-danger', text: "Close\nsome error message")
      assert_nil YAML.safe_load(File.read("#{ondemand_dir}/job_log.yml"))
    end
  end

  test 'editing launchers initializes correctly' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      launcher_id = setup_launcher(project_id)

      visit project_path(project_id)

      edit_launcher_path = edit_project_launcher_path(project_id, launcher_id)
      find("[href='#{edit_launcher_path}']").click

      click_on('Add new option')
      new_field_id = 'add_new_field_select'

      actual_new_options = page.all("##{new_field_id} option").map(&:value).to_set
      expected_new_options = [
        'bc_num_hours', 'auto_queues', 'bc_num_nodes', 'auto_cores',
        'auto_accounts', 'auto_job_name', 'auto_environment_variable',
        'auto_log_location',
      ].to_set
      assert_equal expected_new_options, actual_new_options
    end
  end

  test 'adding new fields to launchers' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      launcher_id = setup_launcher(project_id)

      visit project_path(project_id)

      edit_launcher_path = edit_project_launcher_path(project_id, launcher_id)
      find("[href='#{edit_launcher_path}']").click

      # only shows 'cluster' & 'auto_scripts'
      assert_equal 2, page.all('.editable-form-field').size
      assert_not_nil find('#launcher_auto_batch_clusters')
      assert_not_nil find('#launcher_auto_scripts')
      select('oakley', from: 'launcher_auto_batch_clusters')
      assert_raises(Capybara::ElementNotFound) do
        find('#launcher_bc_num_hours')
      end

      # add bc_num_hours
      add_bc_num_hours(project_id, launcher_id)
      launcher_edit_path = edit_project_launcher_path(project_id, launcher_id)
      find("[href='#{launcher_edit_path}']").click

      # now shows 'cluster', 'auto_scripts' & the newly added'bc_num_hours'
      assert_equal 3, page.all('.editable-form-field').size
      assert_not_nil find('#launcher_auto_batch_clusters')
      assert_not_nil find('#launcher_auto_scripts')
      assert_not_nil find('#launcher_bc_num_hours')

      # edit default, min & max
      find('#edit_launcher_bc_num_hours').click
      fill_in('launcher_bc_num_hours', with: 42)
      fill_in('launcher_bc_num_hours_min', with: 20)
      fill_in('launcher_bc_num_hours_max', with: 101)
      find('#launcher_bc_num_hours_fixed').click
      find('#save_launcher_bc_num_hours').click

      # add auto_environment_variable
      add_auto_environment_variable(project_id, launcher_id)
      find('#edit_launcher_auto_environment_variable').click

      find("[data-auto-environment-variable='name']").fill_in(with: 'SOME_VARIABLE')
      find("#launcher_auto_environment_variable_SOME_VARIABLE").fill_in(with: 'some_value')

      find('#save_launcher_auto_environment_variable').click

      # correctly saves
      click_on(I18n.t('dashboard.save'))
      success_message = I18n.t('dashboard.jobs_launchers_updated')
      assert_selector('.alert-success', text: "Close\n#{success_message}")
      assert_current_path project_path(project_id)

      # note that bc_num_hours has default, min & max
      expected_yml = <<~HEREDOC
        ---
        title: the launcher title
        created_at: #{@expected_now}
        form:
        - auto_scripts
        - auto_batch_clusters
        - bc_num_hours
        - auto_environment_variable_SOME_VARIABLE
        attributes:
          auto_scripts:
            options:
            - - my_cool_script.sh
              - "#{dir}/projects/#{project_id}/my_cool_script.sh"
            - - my_cooler_script.bash
              - "#{dir}/projects/#{project_id}/my_cooler_script.bash"
            value: "#{dir}/projects/#{project_id}/my_cool_script.sh"
            directory: "#{dir}/projects/#{project_id}"
            label: Script
            help: ''
            required: false
          auto_batch_clusters:
            options:
            - - oakley
              - oakley
              - data-max-auto-cores: 80
            - - owens
              - owens
              - data-max-auto-cores: 48
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
          auto_environment_variable_SOME_VARIABLE:
            value: some_value
            label: 'Environment Variable: SOME_VARIABLE'
            help: ''
            required: false
      HEREDOC

      assert_equal(expected_yml, File.read("#{dir}/projects/#{project_id}/.ondemand/launchers/#{launcher_id}/form.yml"))
    end
  end

  test 'removing launcher fields' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      launcher_id = setup_launcher(project_id)

      # add bc_num_hours
      add_bc_num_hours(project_id, launcher_id)
      add_account(project_id, launcher_id)

      # go to edit it and see that there is cluster and bc_num_hours
      visit project_path(project_id)
      edit_launcher_path = edit_project_launcher_path(project_id, launcher_id)
      find("[href='#{edit_launcher_path}']").click
      # puts page.body
      assert_equal 4, page.all('.editable-form-field').size
      assert_not_nil find('#launcher_auto_batch_clusters')
      assert_not_nil find('#launcher_auto_scripts')
      assert_not_nil find('#launcher_bc_num_hours')
      assert_not_nil find('#launcher_auto_accounts')
      select('oakley', from: 'launcher_auto_batch_clusters')

      # remove bc num hours and it's not in the form
      find('#remove_launcher_bc_num_hours').click
      assert_equal 3, page.all('.editable-form-field').size
      assert_not_nil find('#launcher_auto_batch_clusters')
      assert_not_nil find('#launcher_auto_scripts')
      assert_not_nil find('#launcher_auto_accounts')
      assert_raises(Capybara::ElementNotFound) do
        find('#launcher_bc_num_hours')
      end

      # correctly saves
      click_on(I18n.t('dashboard.save'))
      success_message = I18n.t('dashboard.jobs_launchers_updated')
      assert_selector('.alert-success', text: "Close\n#{success_message}")
      assert_current_path project_path(project_id)

      expected_yml = <<~HEREDOC
        ---
        title: the launcher title
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
            value: "#{dir}/projects/#{project_id}/my_cool_script.sh"
            directory: "#{dir}/projects/#{project_id}"
            label: Script
            help: ''
            required: false
          auto_batch_clusters:
            options:
            - - oakley
              - oakley
              - data-max-auto-cores: 80
            - - owens
              - owens
              - data-max-auto-cores: 48
            value: oakley
            label: Cluster
            help: ''
            required: false
      HEREDOC

      assert_equal(expected_yml, File.read("#{dir}/projects/#{project_id}/.ondemand/launchers/#{launcher_id}/form.yml"))
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

  test 'cant create launcher when project is invalid' do
    visit edit_project_launcher_path('1', '1')
    assert_current_path('/projects')
    assert_selector('.alert-danger', text: "Close\nCannot find project: 1")
  end

  test 'cant show launcher when project is invalid' do
    visit project_launcher_path('1', '1')
    assert_current_path('/projects')
    assert_selector('.alert-danger', text: "Close\nCannot find project: 1")
  end

  test 'cant edit launcher when project is invalid' do
    visit edit_project_launcher_path('1', '1')
    assert_current_path('/projects')
    assert_selector('.alert-danger', text: "Close\nCannot find project: 1")
  end

  test 'cant show invalid launcher' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      visit project_launcher_path(project_id, '12345678')
      assert_current_path("/projects/#{project_id}")
      assert_selector('.alert-danger', text: "Close\nCannot find launcher 12345678")
    end
  end

  test 'cant edit invalid launcher' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      visit edit_project_launcher_path(project_id, '12345678')
      assert_current_path("/projects/#{project_id}")
      assert_selector('.alert-danger', text: "Close\nCannot find launcher 12345678")
    end
  end

  # this test:
  # creates a project & launcher with auto_accounts
  # excludes some of the accounts from auto_accounts in launcher#edit
  # asserts that they've actually been removed from launcher#show
  # adds some of the accounts back in launcher#edit
  # asserts that the _new_ list of excluded accounts have actually been removed from launcher#show
  test 'excluding and including select options' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      launcher_id = setup_launcher(project_id)
      add_account(project_id, launcher_id)

      sleep 0.5
      visit edit_project_launcher_path(project_id, launcher_id)

      find('#edit_launcher_auto_accounts').click
      exclude_accounts = ['pas2051', 'pas1871', 'pas1754', 'pas1604']
      exclude_accounts.each do |acct|
        rm_btn = find("#launcher_auto_accounts_remove_#{acct}")
        add_btn = find("#launcher_auto_accounts_add_#{acct}")

        # rm is enabled and add is disabled.
        assert_equal('false', rm_btn[:disabled])
        assert_equal('true', add_btn[:disabled])
        rm_btn.click

        # after clicking, they toggle
        assert_equal('true', rm_btn[:disabled])
        assert_equal('false', add_btn[:disabled])
      end

      find('#save_launcher_edit').click
      assert_current_path(project_path(project_id))
      launcher_path = project_launcher_path(project_id, launcher_id)
      find("[href='#{launcher_path}'].btn-info").click

      # now let's check launchers#show to see if they've actually been excluded.
      show_account_options = page.all('#launcher_auto_accounts option').map(&:value)
      exclude_accounts.each do |acct|
        assert(!show_account_options.include?(acct))
      end

      visit edit_project_launcher_path(project_id, launcher_id)
      find('#edit_launcher_auto_accounts').click

      exclude_accounts.each do |acct|
        rm_btn = find("#launcher_auto_accounts_remove_#{acct}")
        add_btn = find("#launcher_auto_accounts_add_#{acct}")

        # now add is enabled and rm is disabled. (opposite of the above)
        assert_equal('false', add_btn[:disabled])
        assert_equal('true', rm_btn[:disabled])
        add_btn.click

        # after clicking, they toggle
        assert_equal('true', add_btn[:disabled])
        assert_equal('false', rm_btn[:disabled])
      end

      find('#save_launcher_edit').click
      assert_current_path(project_path(project_id))
      launcher_path = project_launcher_path(project_id, launcher_id)
      find("[href='#{launcher_path}'].btn-info").click

      # now let's check launchers#show and they should be back.
      show_account_options = page.all('#launcher_auto_accounts option').map(&:value)
      exclude_accounts.each do |acct|
        assert(show_account_options.include?(acct))
      end
    end
  end

  test 'fixing select options' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      launcher_id = setup_launcher(project_id)
      add_account(project_id, launcher_id)

      sleep 0.5
      visit edit_project_launcher_path(project_id, launcher_id)

      find('#edit_launcher_auto_accounts').click
      accounts_select = find('#launcher_auto_accounts')
      account_options = accounts_select.all('option')
      find("#launcher_auto_accounts_fixed").click

      # Validate that UI changes when field is fixed.
      assert_equal('true', accounts_select[:disabled])
      account_options.each do |option|
        rm_btn = find("#launcher_auto_accounts_remove_#{option.text}")
        add_btn = find("#launcher_auto_accounts_add_#{option.text}")

        option_text_strike = option.selected? ? 0 : 1
        assert_selector("li.text-strike > button#launcher_auto_accounts_add_#{option.text}", count: option_text_strike)
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
      launcher_id = setup_launcher(project_id)
      visit(edit_project_launcher_path(project_id, launcher_id))

      # now add 'auto_accounts'
      click_on('Add new option')
      select('Account', from: 'add_new_field_select')
      click_on(I18n.t('dashboard.add'))
      find('#edit_launcher_auto_accounts').click

      ['pas2051', 'pas1871', 'pas1754', 'pas1604'].each do |acct|
        rm_btn = find("#launcher_auto_accounts_remove_#{acct}")
        add_btn = find("#launcher_auto_accounts_add_#{acct}")

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
      sleep 2

      assert_equal(2, Dir.children(dir).size)
      project_dir = Dir.children(dir).select { |path| File.directory?("#{dir}/#{path}") }.first
      abs_project_dir = "#{dir}/#{project_dir}"

      # 3 shell scripts, 3 forms were copied
      assert_equal(3, Dir.glob("#{abs_project_dir}/*.sh").size)
      forms = Dir.glob("#{abs_project_dir}/.ondemand/**/*/form.yml")
      assert_equal(3, forms.size)

      launcher_id = '8woi7ghd'
      orig_form = "#{Rails.root}/test/fixtures/projects/chemistry-5533/.ondemand/launchers/#{launcher_id}/form.yml"
      orig_form = YAML.safe_load(File.read(orig_form))

      new_form = "#{abs_project_dir}/.ondemand/launchers/#{launcher_id}/form.yml"
      new_form = YAML.safe_load(File.read(new_form))

      # 'form' & 'title' are the same
      assert_equal(orig_form['form'], new_form['form'])
      assert_equal(orig_form['title'], new_form['title'])

      # every auto_scripts option was copied and has the _new_ project location.
      new_auto_scripts = new_form['attributes']['auto_scripts']['options']
      new_auto_scripts.sort_by do |option|
        # ruby 2.7 doesn't sort the same way
        option[0].match('\d').to_s.to_i
      end.each_with_index do |option, idx|
        filename = "assignment_#{idx + 1}.sh"
        full_path = "#{abs_project_dir}/#{filename}"
        assert_equal(filename, option[0])
        assert_equal(full_path, option[1])
      end
    end
  end

  test 'submitting launchers from a template project works' do
    Dir.mktmpdir do |dir|
      # use different accounts than what the template was generated with
      Open3
        .stubs(:capture3)
        .with({}, 'sacctmgr', '-nP', 'show', 'users', 'withassoc', 'format=account,cluster,partition,qos', 'where', 'user=me', stdin_data: '')
        .returns([File.read('test/fixtures/cmd_output/sacctmgr_show_accts_alt.txt'), '', exit_success])

      Project.stubs(:dataroot).returns(Pathname.new(dir))
      Configuration.stubs(:project_template_dir).returns("#{Rails.root}/test/fixtures/projects")

      visit(projects_root_path)
      click_on(I18n.t('dashboard.jobs_create_template_project'))

      select('Chemistry 5533', from: 'project_template')
      click_on(I18n.t('dashboard.save'))

      find('i.fa-atom').click
      input_data = File.read('test/fixtures/projects/chemistry-5533/assignment_1.sh')

      project_dir = Dir.children(dir).select { |p| Pathname.new("#{dir}/#{p}").directory? }.first
      project_dir = "#{dir}/#{project_dir}"

      # NOTE: we're using pzs1715 from sacctmgr_show_accts_alt.txt instead of psz0175
      # from the template.
      Open3
        .stubs(:capture3)
        .with({}, 'sbatch', '-D', project_dir, '-A', 'pzs1715', '--export', 'NONE', '--parsable', '-M', 'owens',
              stdin_data: input_data)
        .returns(['job-id-123', '', exit_success])

      OodCore::Job::Adapters::Slurm.any_instance
                                   .stubs(:info).returns(OodCore::Job::Info.new(id: 'job-id-123', status: :running))

      find("#launch_8woi7ghd").click

      assert_selector('.alert-success', text: 'job-id-123')

      # sleep here because this test can error with Errno::ENOTEMPTY: Directory not empty @ dir_s_rmdir
      # something still has a hold on these files.
      sleep 2
    end
  end
end
