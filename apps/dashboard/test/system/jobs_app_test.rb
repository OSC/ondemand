# frozen_string_literal: true

require 'application_system_test_case'

# Tests /projects URL and the associated code paths
class ProjectsTest < ApplicationSystemTestCase
  def setup
    stub_clusters
    stub_user
    Configuration.stubs(:jobs_app_alpha).returns(true)
    Rails.application.reload_routes!
    Open3
      .stubs(:capture3)
      .with({}, 'sacctmgr', '-nP', 'show', 'users', 'withassoc', 'format=account,cluster,partition,qos', 'where', 'user=me', { stdin_data: '' })
      .returns([File.read('test/fixtures/cmd_output/sacctmgr_show_accts.txt'), '', exit_success])
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
  end

  def script_yml(dir)
    {
      'title'      => 'the script title',
      'form'       => [
        'auto_scripts',
        'auto_accounts'
      ],
      'attributes' => {
        'auto_scripts' => {
          'directory' => dir.to_s
        }
      }
    }.to_yaml
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
      find('[href="/projects/1"]').click
      click_on 'New Script'
      find('#script_title').set('the script title')
      click_on 'Save'
      expected_yml = <<~HEREDOC
        ---
        title: the script title
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

      # init some shell scripts
      script_dir = "#{dir}/projects/1/.ondemand/scripts"
      `mkdir -p #{script_dir}`
      `touch #{dir}/my_cool_script.sh`
      `touch #{dir}/my_cooler_script.bash`

      # now write a new script file
      File.write("#{script_dir}/1.yml", script_yml(dir))

      find('[href="/projects/1"]').click
      find('[href="/projects/1/scripts/1"]').click
      assert_selector('h1', text: 'the script title', count: 1)

      expected_accounts = ['pas1604', 'pas1754', 'pas1871', 'pas2051', 'pde0006', 'pzs0714', 'pzs0715', 'pzs1010',
                           'pzs1117', 'pzs1118', 'pzs1124'].to_set

      assert_equal(expected_accounts, page.all('#script_auto_accounts option').map(&:value).to_set)
      assert_equal(["#{dir}/my_cool_script.sh", "#{dir}/my_cooler_script.bash"].to_set,
                   page.all('#script_auto_scripts option').map(&:value).to_set)

      # clusters are automatically added
      assert_equal(['owens', 'oakley'].to_set, page.all('#script_cluster option').map(&:value).to_set)
    end
  end

  test 'submitting a script with auto attributes that succeeds' do
    Dir.mktmpdir do |dir|
      setup_project(dir)

      # init some shell scripts
      script_dir = "#{dir}/projects/1/.ondemand/scripts"
      `mkdir -p #{script_dir}`
      `echo 'some_other_command' > #{dir}/my_cool_script.sh`
      `echo 'hostname' > #{dir}/my_cooler_script.bash`

      # now write a new script file
      File.write("#{script_dir}/1.yml", script_yml(dir))

      find('[href="/projects/1"]').click
      find('[href="/projects/1/scripts/1"]').click
      assert_selector('h1', text: 'the script title', count: 1)

      # assert defaults
      assert_equal 'oakley', find('#script_cluster').value
      assert_equal 'pzs0715', find('#script_auto_accounts').value
      assert_equal "#{dir}/my_cool_script.sh", find('#script_auto_scripts').value
      assert_nil YAML.safe_load(File.read("#{script_dir}/1_job_log"))

      select('owens', from: 'script_cluster')
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

      # init some shell scripts
      script_dir = "#{dir}/projects/1/.ondemand/scripts"
      `mkdir -p #{script_dir}`
      `echo 'some_other_command' > #{dir}/my_cool_script.sh`
      `echo 'hostname' > #{dir}/my_cooler_script.bash`

      # now write a new script file
      File.write("#{script_dir}/1.yml", script_yml(dir))

      find('[href="/projects/1"]').click
      find('[href="/projects/1/scripts/1"]').click
      assert_selector('h1', text: 'the script title', count: 1)

      # assert defaults
      assert_equal 'oakley', find('#script_cluster').value
      assert_equal 'pzs0715', find('#script_auto_accounts').value
      assert_equal "#{dir}/my_cool_script.sh", find('#script_auto_scripts').value
      assert_nil YAML.safe_load(File.read("#{script_dir}/1_job_log"))

      select('owens', from: 'script_cluster')
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
end
