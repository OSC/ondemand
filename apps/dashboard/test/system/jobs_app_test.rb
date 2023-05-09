# frozen_string_literal: true

require 'application_system_test_case'

# Tests /projects URL and the associated code paths
class ProjectsTest < ApplicationSystemTestCase
  def setup
    stub_clusters
    stub_user
    Configuration.stubs(:jobs_app_alpha).returns(true)
    Rails.application.reload_routes!
    stub_sacctmgr
    stub_scontrol
  end

  def setup_project(dir)
    OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))
    proj = 'test-project'
    icon = 'fas://arrow-right'
    visit projects_path
    click_on I18n.t('dashboard.jobs_create_blank_project')
    find('#project_name').set(proj)
    find('#product_icon_select').set(icon)
    click_on 'Save'

    `echo 'some_other_command' > #{dir}/projects/1/my_cool_script.sh`
    `echo 'hostname' > #{dir}/projects/1/my_cooler_script.bash`
  end

  def setup_script(project_id)
    visit project_path(project_id)
    click_on 'New Script'
    find('#script_title').set('the script title')
    click_on 'Save'
  end

  # TODO: fix tests once you can add auto_accounts through the ui
  def hack_script(project_dir)
    hack = <<~HEREDOC
      ---
      title: the script title
      form:
      - auto_batch_clusters
      - auto_scripts
      - auto_accounts
      attributes:
        auto_scripts:
          directory: #{project_dir}
        auto_batch_clusters:
          options:
          - oakley
          - owens
    HEREDOC

    File.write("#{project_dir}/.ondemand/scripts/1.yml", hack)
  end

  def add_bc_num_hours(project_id)
    visit project_path(project_id)
    find("[href='/projects/#{project_id}/scripts/1/edit']").click

    # now add 'bc_num_hours'
    click_on('Add new option')
    select('Hours', from: 'add_new_field_select')
    click_on(I18n.t('dashboard.add'))
    fill_in('script_bc_num_hours', with: 1)
  end

  test 'create a new project on fs and display the table entry' do
    Dir.mktmpdir do |dir|
      setup_project(dir)

      assert_selector '.alert-success', text: 'Project successfully created!'
      assert_selector '[href="/projects/1"]', text: 'Test Project'
      assert File.directory? File.join("#{dir}/projects", '1')
    end
  end

  test 'creates .ondemand directory with project' do
    Dir.mktmpdir do |dir|
      setup_project(dir)

      assert File.directory? File.join("#{dir}/projects", '1/.ondemand')
    end
  end

  test 'delete a project from the fs and ensure no table entry' do
    Dir.mktmpdir do |dir|
      setup_project(dir)

      accept_confirm do
        click_on 'Delete'
      end

      assert_selector '.alert-success', text: 'Project successfully deleted!'
      assert_no_selector '[href="/projects/1"]', text: 'Test Project'
      assert_not File.directory? File.join("#{dir}/projects", '1')
    end
  end

  test 'work in a project' do
    Dir.mktmpdir do |dir|
      setup_project(dir)

      find('[href="/projects/1"]').click
      assert_selector 'h1', text: 'Test Project'
      assert_selector '.btn.btn-default', text: 'Back'
    end
  end

  test 'edit a project' do
    Dir.mktmpdir do |dir|
      setup_project(dir)

      click_on 'Edit'
      find('#project_name').set('my-test-project')
      click_on 'Save'
      assert_selector '[href="/projects/1"]', text: 'My Test Project'
      click_on 'Edit'
      assert_selector 'h1', text: 'Editing: My Test Project'
      assert_selector '.btn.btn-default', text: 'Back'
    end
  end

  test 'create with missing icon triggers alert' do
    Dir.mktmpdir do |dir|
      OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))
      proj = 'test-project'
      icon = ''
      visit projects_path
      click_on I18n.t('dashboard.jobs_create_blank_project')
      find('#project_name').set(proj)
      find('#product_icon_select').set(icon)
      click_on 'Save'

      assert_selector '.alert-danger', text: 'Icon format invalid or missing'
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

      assert_selector '.alert-danger', text: 'Icon format invalid or missing'
    end
  end

  test 'update with invalid icon' do
    Dir.mktmpdir do |dir|
      setup_project(dir)
      click_on 'Edit'
      find('#product_icon_select').set('fas://bad&icon')
      click_on 'Save'

      assert_selector '.alert-danger', text: 'Icon format invalid or missing'
    end
  end

  test 'creating and showing scripts' do
    Dir.mktmpdir do |dir|
      setup_project(dir)
      setup_script(1)

      expected_yml = <<~HEREDOC
        ---
        title: the script title
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
              - "#{dir}/projects/1/my_cool_script.sh"
            - - my_cooler_script.bash
              - "#{dir}/projects/1/my_cooler_script.bash"
            directory: "#{dir}/projects/1"
            label: Script
            help: ''
            required: false
      HEREDOC

      assert_selector('.alert-success', text: "×\nClose\nsucess!")
      assert_equal(expected_yml, File.read("#{dir}/projects/1/.ondemand/scripts/1.yml"))

      find('[href="/projects/1/scripts/1"]').click
      assert_selector('h1', text: 'the script title', count: 1)
    end
  end

  test 'showing scripts with auto attributes' do
    Dir.mktmpdir do |dir|
      setup_project(dir)
      setup_script(1)
      project_dir = "#{dir}/projects/1"
      hack_script(project_dir)

      find('[href="/projects/1/scripts/1"]').click
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

  test 'submitting a script with auto attributes that succeeds' do
    Dir.mktmpdir do |dir|
      setup_project(dir)
      setup_script(1)
      project_dir = "#{dir}/projects/1"
      script_dir = "#{project_dir}/.ondemand/scripts"
      hack_script(project_dir)

      find('[href="/projects/1/scripts/1"]').click
      assert_selector('h1', text: 'the script title', count: 1)

      # assert defaults
      assert_equal 'oakley', find('#script_auto_batch_clusters').value
      assert_equal 'pzs0715', find('#script_auto_accounts').value
      assert_equal "#{project_dir}/my_cool_script.sh", find('#script_auto_scripts').value
      assert_nil YAML.safe_load(File.read("#{script_dir}/1_job_log"))

      select('owens', from: 'script_auto_batch_clusters')
      select('pas2051', from: 'script_auto_accounts')
      select('my_cooler_script.bash', from: 'script_auto_scripts')

      Open3
        .stubs(:capture3)
        .with({}, 'sbatch', '-A', 'pas2051', '--export', 'NONE', '--parsable', '-M', 'owens',
              { stdin_data: "hostname\n" })
        .returns(['job-id-123', '', exit_success])

      OodCore::Job::Adapters::Slurm.any_instance
                                   .stubs(:info).returns(OodCore::Job::Info.new(id: 'job-id-123', status: :running))

      Time
        .stubs(:now)
        .returns(Time.at(1_679_943_564))

      click_on 'Launch'
      assert_selector('.alert-success', text: 'job-id-123')
      assert_equal [{ 'id'          => 'job-id-123',
                      'submit_time' => 1_679_943_564,
                      'cluster'     => 'owens' }],
                   YAML.safe_load(File.read("#{script_dir}/1_job_log"))
    end
  end

  test 'submitting a script with auto attributes that fails' do
    Dir.mktmpdir do |dir|
      setup_project(dir)
      setup_script(1)
      project_dir = "#{dir}/projects/1"
      script_dir = "#{project_dir}/.ondemand/scripts"
      hack_script(project_dir)

      find('[href="/projects/1/scripts/1"]').click
      assert_selector('h1', text: 'the script title', count: 1)

      # assert defaults
      assert_equal 'oakley', find('#script_auto_batch_clusters').value
      assert_equal 'pzs0715', find('#script_auto_accounts').value
      assert_equal "#{project_dir}/my_cool_script.sh", find('#script_auto_scripts').value
      assert_nil YAML.safe_load(File.read("#{script_dir}/1_job_log"))

      select('owens', from: 'script_auto_batch_clusters')
      select('pas2051', from: 'script_auto_accounts')
      select('my_cooler_script.bash', from: 'script_auto_scripts')

      Open3
        .stubs(:capture3)
        .with({}, 'sbatch', '-A', 'pas2051', '--export', 'NONE', '--parsable', '-M', 'owens',
              { stdin_data: "hostname\n" })
        .returns(['', 'some error message', exit_failure])

      click_on 'Launch'
      assert_selector('.alert-danger', text: "×\nClose\nsome error message")
      assert_nil YAML.safe_load(File.read("#{script_dir}/1_job_log"))
    end
  end

  test 'editing scripts initializes correctly' do
    Dir.mktmpdir do |dir|
      setup_project(dir)
      setup_script('1')

      visit project_path('1')
      find('[href="/projects/1/scripts/1/edit"]').click

      click_on('Add new option')
      new_field_id = 'add_new_field_select'

      actual_new_options = page.all("##{new_field_id} option").map(&:value).to_set
      expected_new_options = ['bc_num_hours', 'auto_queues', 'bc_num_slots'].to_set
      assert_equal expected_new_options, actual_new_options
    end
  end

  test 'adding new fields to scripts' do
    Dir.mktmpdir do |dir|
      setup_project(dir)
      setup_script('1')

      visit project_path('1')
      find('[href="/projects/1/scripts/1/edit"]').click

      # only shows 'cluster' & 'auto_scripts'
      assert_equal 2, page.all('.form-group').size
      assert_not_nil find('#script_auto_batch_clusters')
      assert_not_nil find('#script_auto_scripts')
      select('oakley', from: 'script_auto_batch_clusters')
      assert_raises(Capybara::ElementNotFound) do
        find('#script_bc_num_hours')
      end

      # add bc_num_hours
      add_bc_num_hours(1)

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
      find('#save_script_bc_num_hours').click

      # correctly saves
      click_on(I18n.t('dashboard.save'))
      assert_selector('.alert-success', text: "×\nClose\nsucess!")
      assert_current_path '/projects/1'

      # note that bc_num_hours has default, min & max
      expected_yml = <<~HEREDOC
        ---
        title: the script title
        form:
        - auto_scripts
        - auto_batch_clusters
        - bc_num_hours
        attributes:
          auto_scripts:
            options:
            - - my_cool_script.sh
              - "#{dir}/projects/1/my_cool_script.sh"
            - - my_cooler_script.bash
              - "#{dir}/projects/1/my_cooler_script.bash"
            directory: "#{dir}/projects/1"
            value: "#{dir}/projects/1/my_cool_script.sh"
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
            max: 101
            label: Number of hours
            help: ''
            required: true
      HEREDOC

      assert_equal(expected_yml, File.read("#{dir}/projects/1/.ondemand/scripts/1.yml"))
    end
  end

  # TODO: there's a bug in saving select options like 'cluster'
  # test 'removing script fields' do
  #   Dir.mktmpdir do |dir|
  #     setup_project(dir)
  #     setup_script('1')

  #     # add bc_num_hours
  #     add_bc_num_hours(1)
  #     click_on(I18n.t('dashboard.save'))

  #     puts `cat #{dir}/projects/1/.ondemand/scripts/1.yml`

  #     # go to edit it and see that there is cluster and bc_num_hours
  #     visit project_path('1')
  #     find('[href="/projects/1/scripts/1/edit"]').click
  #     assert_equal 3, page.all('.form-group').size
  #     assert_not_nil find('#script_cluster')
  #     assert_not_nil find('#script_auto_scripts')
  #     assert_not_nil find('#script_bc_num_hours')
  #     select('oakley', from: 'script_cluster')

  #     # remove bc num hours and it's not in the form
  #     find('#remove_script_bc_num_hours').click
  #     assert_equal 1, page.all('.form-group').size
  #     assert_not_nil find('#script_cluster')
  #     assert_not_nil find('#script_auto_scripts')
  #     assert_raises(Capybara::ElementNotFound) do
  #       find('#script_bc_num_hours')
  #     end

  #     # correctly saves
  #     click_on(I18n.t('dashboard.save'))
  #     assert_selector('.alert-success', text: "×\nClose\nsucess!")
  #     assert_current_path '/projects/1'

  #     expected_yml = <<~HEREDOC
  #       ---
  #       title: the script title
  #       form:
  #       - cluster
  #       attributes:
  #         cluster:
  #           value: oakley
  #           label: Cluster
  #           help: ''
  #           required: false
  #     HEREDOC

  #     assert_equal(expected_yml, File.read("#{dir}/projects/1/.ondemand/scripts/1.yml"))
  #   end
  # end
end
