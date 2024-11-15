# frozen_string_literal: true

require 'test_helper'

class ProjectsTest < ActiveSupport::TestCase
  test 'create empty project' do
    project = Project.new

    assert_nil project.id
    assert_nil project.directory
    assert_equal '', project.name
    assert_equal '', project.description
    assert_equal '', project.icon
  end

  test 'create project validation' do
    Dir.mktmpdir do |tmp|
      OodAppkit.stubs(:dataroot).returns(Pathname.new(tmp))

      project = Project.new({})
      assert_not project.save
      assert_equal 1, project.errors.size
      assert_not project.errors[:name].empty?

      invalid_directory = Project.dataroot
      invalid_icon = 'invalid_format'
      project = Project.new({ name: 'test', icon: invalid_icon, directory: invalid_directory.to_s,
template: '/invalid/template' })

      assert_not project.save
      assert_equal 3, project.errors.size
      assert_not_equal invalid_icon, project.icon 
      assert_not project.errors[:directory].empty?
      assert_not project.errors[:template].empty?
      assert_equal(1, project.errors[:directory].size)
      assert_equal(2, project.errors[:template].size)
    end
  end

  test 'creates project should not load manifest if directory points to another project' do
    stub_du
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      existing_project = create_project(projects_path, name: 'Existing Project', description: 'Existing Description',
icon: 'fas://existing')

      new_project = Project.new({ directory: existing_project.directory })

      # Check id and directory defaults
      assert_nil new_project.id
      assert_equal '', new_project.name
      assert_equal '', new_project.description
      assert_equal '', new_project.icon
      assert_equal existing_project.directory, new_project.directory
    end
  end

  test 'creates project defaults' do
    stub_du
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      project = create_project(projects_path, name: 'MyLocalName', description: 'MyLocalDescription', icon: nil)

      # Check id and directory defaults
      assert_not_nil project.id
      assert_equal "#{projects_path}/projects/#{project.id}", project.directory
      assert_equal 'fas://cog', project.icon
    end
  end

  test 'creates project' do
    stub_du
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      project_id = Project.next_id
      project = create_project(projects_path, id: project_id, name: 'MyLocalName', description: 'MyLocalDescription',
icon: 'fas://test')

      assert project.errors.inspect
      assert Dir.entries("#{projects_path}/projects").include?(project_id)
      assert_equal project_id, project.id
      assert_equal 'MyLocalName', project.name
      assert_equal "#{projects_path}/projects/#{project_id}", project.directory
      assert_equal 'MyLocalDescription', project.description
      assert_equal 'fas://test', project.icon
      assert_equal 2_097_152, project.size
    end
  end

  test 'creates project with directory override' do
    Dir.mktmpdir do |tmp|
      projects_root = Pathname.new(tmp)
      project_dir = File.join(tmp, 'dir_override')
      project = create_project(projects_root, directory: project_dir)

      assert_equal project_dir, project.directory
      assert File.directory?(Pathname.new(project_dir))
      assert File.file?(Pathname.new("#{project_dir}/.ondemand/manifest.yml"))
    end
  end

  test 'creates project with template copies template files' do
    Dir.mktmpdir do |tmp|
      template_dir = File.join(tmp, 'template')
      file_content = <<~HEREDOC
        some multiline content
        echo 'multiline content'
        description: multiline content
      HEREDOC
      Pathname.new(template_dir).mkpath
      File.open("#{template_dir}/script.sh", 'w') { |file| file.write(file_content) }
      File.open("#{template_dir}/info.txt", 'w') { |file| file.write(file_content) }
      File.open("#{template_dir}/config.yml", 'w') { |file| file.write(file_content) }

      Configuration.stubs(:project_template_dir).returns(tmp)
      projects_path = Pathname.new(tmp)
      project = create_project(projects_path, template: template_dir)

      assert Dir.entries(project.directory).include?('script.sh')
      assert Dir.entries(project.directory).include?('info.txt')
      assert Dir.entries(project.directory).include?('config.yml')
    end
  end

  test 'create project with template does not copy project specific files' do
    Dir.mktmpdir do |tmp|
      template_dir = File.join(tmp,'template')
      job_log_path = "#{template_dir}/.ondemand/job_log.yml"
      launcher_id = '50r4nd0m'
      cache_json_path = "#{template_dir}/.ondemand/launchers/#{launcher_id}/cache.json"

      file_content = <<~HEREDOC
        some multiline content
        echo 'multiline content'
        description: multiline content
      HEREDOC
      Pathname.new("#{template_dir}/.ondemand/launchers/#{launcher_id}").mkpath
      File.open(job_log_path, 'w') { |file| file.write(file_content) }
      File.open(cache_json_path, 'w') { |file| file.write(file_content) }

      Configuration.stubs(:project_template_dir).returns(tmp)
      projects_path = Pathname.new(tmp)
      project = create_project(projects_path, template: template_dir)
      
      assert Dir.glob(cache_json_path).present? && 
        Dir.glob("#{project.directory}/.ondemand/launchers/*/cache.json").empty?
      assert Dir.glob(job_log_path).present? &&
        Dir.glob("#{project.directory}/.ondemand/*").exclude?("#{project.directory}/.ondemand/job_log.yml")
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
      project = create_project(projects_path, id: "test-#{Project.next_id}")

      assert project.errors.inspect
      assert_equal "#{projects_path}/projects/#{project.id}", project.directory.to_s

      manifest_path = Pathname.new("#{projects_path}/projects/#{project.id}/.ondemand/manifest.yml")

      assert File.file?(manifest_path)

      expected_manifest_yml = <<~HEREDOC
        ---
        id: #{project.id}
        name: test-project
        description: description
        icon: fas://arrow-right
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

      project = create_project(projects_path, id: "test-#{Project.next_id}")

      name          = 'test-project-2'
      description   = 'my test project'
      icon          = 'fas://arrow-left'

      test_attributes = { name: name, description: description, icon: icon }

      expected_manifest_yml = <<~HEREDOC
        ---
        id: #{project.id}
        name: test-project-2
        description: my test project
        icon: fas://arrow-left
      HEREDOC

      assert project.update(test_attributes)

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

      assert project.update({ id: 'updated', name: 'updated', icon: 'fas://updated', directory: '/updated',
description: 'updated', template: '/some/path' })
      assert_equal 'updated', project.name
      assert_equal 'fas://updated', project.icon
      assert_equal 'updated', project.description

      assert_equal old_id, project.id
      assert_equal old_directory, project.directory
      assert_nil project.template
    end
  end

  test 'update project validation' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      project = create_project(projects_path)

      assert_not project.update({ name: nil, icon: nil })
      assert_equal 1, project.errors.size
      assert_not project.errors[:name].empty?
      assert_equal 'fas://cog', project.icon
    end
  end

  def create_project(projects_path, id: nil, name: 'test-project', icon: 'fas://arrow-right', description: 'description', directory: nil, template: nil)
    OodAppkit.stubs(:dataroot).returns(projects_path)
    attrs = { name: name, icon: icon, id: id, description: description, directory: directory, template: template }
    project = Project.new(attrs)
    assert project.save, project.collect_errors

    project
  end
end
