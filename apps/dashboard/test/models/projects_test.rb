# frozen_string_literal: true

require 'test_helper'

class ProjectsTest < ActiveSupport::TestCase
  test 'creates project' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      attrs = { name: 'test-project', icon: 'fas://arrow-right', id: 1 }
      project = Project.new(attrs)

      assert project.save(attrs), project.errors.inspect
      assert Dir.entries("#{projects_path}/projects").include?('1')
    end
  end

  test 'save rejects bad name characters at validation' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)

      attrs = { name: "b@d-$ym?o|'s", icon: 'fas://arrow-right', id: 1 }
      project = Project.new(attrs)

      assert !project.save(attrs)
      assert_equal project.errors[:name].last, 'Name format invalid'
    end
  end

  test 'update writes manifest and rejects name with disallowed characters' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)

      attrs = { name: "test project", icon: 'fas://arrow-right', id: 1 }
      project = Project.new(attrs)
      project.save(attrs)

      bad_attrs = { name: 'b@d $ymbo!s' }

      assert !project.update(bad_attrs)
      assert_equal project.errors[:name].last, 'Name format invalid'

      good_attrs = { name: 'good-symbols', icon: 'fas://arrow-right', id: 1 }
      manifest_path = Pathname.new("#{project.directory}/.ondemand/manifest.yml")

      expected_manifest_yml = <<~HEREDOC
        ---
        name: good symbols
        icon: fas://arrow-right
      HEREDOC

      assert project.update(good_attrs), project.errors.inspect
      assert expected_manifest_yml, File.read(manifest_path)
    end
  end

  test 'creates .ondemand configuration directory' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      attrs = { name: 'test-project', icon: 'fas://arrow-right', id: 1 }
      project = Project.new(attrs)

      assert project.save(attrs)
      assert Dir.entries(project.directory).include?('.ondemand')
    end
  end

  test 'creates manifest.yml in .ondemand config directory' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      attrs = { name: 'test-project', icon: 'fas://arrow-right', id: 1 }
      project = Project.new(attrs)

      assert project.save(attrs), project.errors.inspect
      assert_equal "#{projects_path}/projects/1", project.directory.to_s

      manifest_path = Pathname.new("#{projects_path}/projects/1/.ondemand/manifest.yml")

      assert File.file?(manifest_path)

      expected_manifest_yml = <<~HEREDOC
        ---
        name: test-project
        icon: fas://arrow-right
      HEREDOC

      assert_equal expected_manifest_yml, File.read(manifest_path)
    end
  end

  test 'deletes project' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      attrs = { name: 'test-project', icon: 'fas://arrow-right', id: 1 }
      project = Project.new(attrs)

      assert project.save(attrs)
      assert Dir.entries("#{projects_path}/projects/").include?('1')

      project.destroy!
      assert_not Dir.entries("#{projects_path}/projects/").include?('1')
    end
  end

  test 'update project manifest.yml file' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      attrs = { name: 'test-project', icon: 'fas://arrow-right', id: 1 }
      project = Project.new(attrs)
      assert project.save(attrs)

      name          = 'test-project-2'
      description   = 'my test project'
      icon          = 'fas://arrow-left'

      test_attributes = { name: name, description: description, icon: icon }

      expected_manifest_yml = <<~HEREDOC
        ---
        name: test-project-2
        icon: fas://arrow-left
        description: my test project
      HEREDOC

      puts "project: #{project.inspect}"

      assert project.update(test_attributes)

      puts "project: #{project.inspect}"

      assert File.exist?(project.manifest_path.to_s)

      assert_equal expected_manifest_yml, File.read(project.manifest_path.to_s)
    end
  end

  test 'icon defaults to fas://cog' do
    Dir.mktmpdir do |tmp|
      project_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(project_path)
      attrs = { name: 'test-project', description: 'test description', id: 1 }

      project = Project.new(attrs)
      assert project.save(attrs), project.errors.inspect

      manifest_yml = <<~HEREDOC
        ---
        name: test-project
        description: test description
        icon: fas://cog
      HEREDOC

      assert_equal manifest_yml, File.read(project.manifest_path.to_s)
    end
  end
end
