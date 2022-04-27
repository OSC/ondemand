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
      assert_selector 'tbody tr td', text: 'test_project'
      assert File.directory? File.join("#{dir}/projects", 'test_project')
    end
  end

  test 'creates .ondemand directory with project' do
    Dir.mktmpdir do |dir|
      setup_project(dir)

      assert File.directory? File.join("#{dir}/projects", 'test_project/.ondemand')
    end
  end

  test 'delete a project from the fs and ensure no table entry' do
    Dir.mktmpdir do |dir|
      setup_project(dir)

      click_on 'Delete'
      find('.btn.commit.btn-danger').click

      assert_selector '.alert-success', text: 'Project successfully deleted!'
      assert_no_selector 'tbody tr td', text: 'test_project'
      assert_not File.directory? File.join("#{dir}/projects", 'test_project')
    end
  end

  test 'work in a project' do
    Dir.mktmpdir do |dir|
      setup_project(dir)

      find('.btn.btn-success').click
      assert_selector 'h1', text: 'Project Space'
      assert_selector '.btn.btn-default', text: 'Back'
    end
  end

  test 'edit a project' do
    Dir.mktmpdir do |dir|
      setup_project(dir)

      find('tbody .btn.btn-info').click
      find('#project_name').set("my test project")
      click_on 'Save'
      find('tbody .btn.btn-info').click
      assert_selector 'h1', text: 'Editing: My Test Project'
      assert_selector '.btn.btn-default', text: 'Back'
    end
  end

  def setup_project(dir)
    OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))
    src = 'test_project'
    visit projects_path
    click_on 'New Project'
    find('#project_name').set(src)
    click_on 'Save'
  end
end
