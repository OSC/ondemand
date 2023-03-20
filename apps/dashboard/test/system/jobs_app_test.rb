# frozen_string_literal: true

require 'application_system_test_case'

class ProjectsTest < ApplicationSystemTestCase

  def setup
    Configuration.stubs(:jobs_app_alpha).returns(true)
    Rails.application.reload_routes!
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
      assert_selector 'h1', text: 'Project Space'
      assert_selector '.btn.btn-default', text: 'Back'
    end
  end

  test 'edit a project' do
    Dir.mktmpdir do |dir|
      setup_project(dir)

      click_on 'Edit'
      find('#project_name').set("my-test-project")
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
      click_on I18n.t('dashboard.jobs_project_create_new_project_directory')
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
      click_on I18n.t('dashboard.jobs_project_create_new_project_directory')
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

  def setup_project(dir)
    OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))
    proj = 'test-project'
    icon = 'fas://arrow-right'
    visit projects_path
    click_on I18n.t('dashboard.jobs_project_create_new_project_directory')
    find('#project_name').set(proj)
    find('#product_icon_select').set(icon)
    click_on 'Save'
  end
end
