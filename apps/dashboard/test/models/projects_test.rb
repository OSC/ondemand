# frozen_string_literal: true

require 'test_helper'

class ProjectsTest < ActiveSupport::TestCase
  test 'creates project' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      attrs = { name: 'test project' }
      project = Project.new(attrs)
      project.save(attrs)

      assert Dir.entries("#{projects_path}/projects").include?('test_project')
    end
  end

  test 'save rejects bad characters at validation' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)

      attrs = { name: "b@d $ym?o|'s" }
      project = Project.new(attrs)

      assert !project.save(attrs)
      assert_equal project.errors[:name].last, I18n.t('dashboard.jobs_project_name_validation')
    end
  end

  test 'update writes manifest and rejects name with disallowed characters' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)

      attrs = { name: 'test project' }
      project = Project.new(attrs)
      project.save(attrs)

      bad_attrs = { name: 'b@d $ymbo!s' }

      assert !project.update(bad_attrs)
      assert_equal project.errors[:name].last, I18n.t('dashboard.jobs_project_name_validation')

      good_attrs = { name: 'good symbols' }
      manifest_path = Pathname.new("#{projects_path}/projects/#{project.directory}/.ondemand/manifest.yml")

      expected_manifest_yml = <<~HEREDOC
        ---
        name: good symbols
      HEREDOC

      assert project.update(good_attrs)
      assert expected_manifest_yml, File.read(manifest_path)
    end
  end

  test 'creates .ondemand configuration directory' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      attrs = { name: 'test project' }
      project = Project.new(attrs)
      project.save(attrs)

      dot_ondemand_path = Pathname.new("#{projects_path}/projects/#{project.directory}")

      assert Dir.entries(dot_ondemand_path).include?('.ondemand')
    end
  end

  test 'creates manifest.yml in .ondemand config directory' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      attrs = { name: 'test project' }
      project = Project.new(name: 'test project')
      project.save(attrs)

      assert_equal 'test_project', project.directory

      manifest_path = Pathname.new("#{projects_path}/projects/#{project.directory}/.ondemand/manifest.yml")

      assert File.file?(manifest_path)

      expected_manifest_yml = <<~HEREDOC
        ---
        name: test project
      HEREDOC

      assert_equal expected_manifest_yml, File.read(manifest_path)
    end
  end

  test 'deletes project' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      attrs = { name: 'test project' }
      project = Project.new(attrs)

      project.save(attrs)
      assert Dir.entries("#{projects_path}/projects/").include?('test_project')

      project.destroy!
      assert_not Dir.entries("#{projects_path}/projects/").include?('test_project')
    end
  end

  test 'update project manifest.yml file' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      attrs = { name: 'test project' }
      project = Project.new(attrs)
      project.save(attrs)

      name          = 'galaxies and galaxies'
      description   = 'a view into the past'
      icon          = 'fa://abell_1689'

      test_attributes = { name: name, description: description, icon: icon }

      expected_manifest_yml = <<~HEREDOC
        ---
        name: galaxies and galaxies
        description: a view into the past
        icon: fa://abell_1689
      HEREDOC

      project.update(test_attributes)

      assert_equal expected_manifest_yml, File.read(project.manifest_path.to_s)
    end
  end
end
