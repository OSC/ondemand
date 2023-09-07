# frozen_string_literal: true

require 'test_helper'

class ProjectsTest < ActiveSupport::TestCase
  test 'crate project validation' do
    Dir.mktmpdir do |tmp|
      OodAppkit.stubs(:dataroot).returns(Pathname.new(tmp))

      project = Project.new({})
      assert_not project.save
      assert_equal 1, project.errors.size
      assert_not project.errors[:name].empty?

      invalid_directory = Project.dataroot
      project = Project.new({ name: 'test', icon: 'invalid_format', directory: invalid_directory.to_s })

      assert_not project.save
      assert_equal 2, project.errors.size
      assert_not project.errors[:icon].empty?
      assert_not project.errors[:directory].empty?
    end
  end

  test 'creates project' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      project = create_project(projects_path)

      assert project.errors.inspect
      assert Dir.entries("#{projects_path}/projects").include?(project.id)
    end
  end

  test 'creates .ondemand configuration directory' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      project = create_project(projects_path)

      assert Dir.entries(project.directory).include?('.ondemand')
    end
  end

  test 'creates manifest.yml in .ondemand config directory' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      project = create_project(projects_path)

      assert project.errors.inspect
      assert_equal "#{projects_path}/projects/#{project.id}", project.directory.to_s

      manifest_path = Pathname.new("#{projects_path}/projects/#{project.id}/.ondemand/manifest.yml")

      assert File.file?(manifest_path)

      expected_manifest_yml = <<~HEREDOC
        ---
        name: test-project
        icon: fas://arrow-right
        description: description
      HEREDOC

      assert_equal expected_manifest_yml, File.read(manifest_path)
    end
  end

  test 'deletes project' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      project = create_project(projects_path)

      assert Dir.entries("#{projects_path}/projects/").include?(project.id)
      assert Dir.entries("#{projects_path}/projects/#{project.id}").include?('.ondemand')

      project.destroy!
      assert Dir.entries("#{projects_path}/projects/").include?(project.id)
      assert_not Dir.entries("#{projects_path}/projects/#{project.id}").include?('.ondemand')
    end
  end

  test 'update project manifest.yml file' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      project = create_project(projects_path)

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

  test 'update project only updates name, icon, and description' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      project = create_project(projects_path)
      old_id = project.id
      old_directory = project.directory

      assert project.update({ id: 'updated', name: 'updated', icon: 'fas://updated', directory: '/updated', description: 'updated' })
      assert_equal 'updated', project.name
      assert_equal 'fas://updated', project.icon
      assert_equal 'updated', project.description

      assert_equal old_id, project.id
      assert_equal old_directory, project.directory
    end
  end

  test 'update project validation' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      project = create_project(projects_path)

      assert_not project.update({ name: nil, icon: nil })
      assert_equal 2, project.errors.size
      assert_not project.errors[:name].empty?
      assert_not project.errors[:icon].empty?
    end
  end

  def create_project(projects_path, name: 'test-project', icon: 'fas://arrow-right', description: 'description', directory: nil)
    OodAppkit.stubs(:dataroot).returns(projects_path)
    id = Project.next_id
    directory = Project.dataroot.join(id.to_s).to_s if directory.blank?
    attrs = { name: name, icon: icon, id: id, description: description, directory: directory }
    project = Project.new(attrs)
    assert project.save

    project
  end

end
