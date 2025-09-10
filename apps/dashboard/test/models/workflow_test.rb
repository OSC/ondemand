# frozen_string_literal: true

require 'test_helper'

class WorkflowsTest < ActiveSupport::TestCase
  test 'create empty workflow' do
    workflow = Workflow.new

    assert_nil workflow.id
    assert_nil workflow.project_dir
    assert_nil workflow.name
    assert_nil workflow.description
    assert_nil workflow.created_at
    assert_equal [], workflow.launcher_ids
    assert_equal [], workflow.source_ids
    assert_equal [], workflow.target_ids
  end

  test 'create workflow validation' do
    Dir.mktmpdir do |tmp|
      # add error in workflow save if project_dir is not valid
      # workflow = Workflow.new({})
      # assert_not workflow.save
      # assert_equal 1, workflow.errors.size
      # assert_not workflow.errors[:name].empty?

      invalid_directory = tmp
      workflow = Workflow.new({ name: 'test', project_dir: invalid_directory.to_s})

      assert workflow.save
      assert_equal 0, workflow.errors.size
    end
  end

  test 'creates workflow defaults' do
    stub_du
    Dir.mktmpdir do |tmp|
      project_dir = Pathname.new(tmp)
      workflow = create_workflow(name: 'MyLocalName', description: 'MyLocalDescription', project_dir: project_dir)

      # Check id and directory defaults
      assert_not_nil workflow.id
      assert_equal "#{project_dir}/.ondemand/workflows", Workflow.workflow_dir(project_dir).to_s
    end
  end

  test 'creates workflow' do
    stub_du
    Dir.mktmpdir do |tmp|
      project_dir = Pathname.new(tmp)
      workflow_id = Workflow.next_id
      workflow = create_workflow(id: workflow_id, name: 'MyLocalName', description: 'MyLocalDescription', project_dir: project_dir)

      assert workflow.errors.inspect
      assert Dir.entries("#{project_dir}/.ondemand/workflows").include?("#{workflow_id}.yml")
      assert_equal workflow_id, workflow.id
      assert_equal 'MyLocalName', workflow.name
      assert_equal 'MyLocalDescription', workflow.description
    end
  end

  test 'creates manifest file in .ondemand/workflows config directory' do
    Dir.mktmpdir do |tmp|
      project_dir = Pathname.new(tmp)
      workflow = create_workflow(id: "test-#{Workflow.next_id}", project_dir: project_dir)

      assert workflow.errors.inspect
      manifest_file = Pathname.new("#{project_dir}/.ondemand/workflows/#{workflow.id}.yml")
      assert_equal manifest_file, workflow.manifest_file
      assert File.file?(manifest_file)

      manifest_data = YAML.safe_load(File.read(manifest_file), permitted_classes: [Pathname], aliases: true)

      assert_equal workflow.id, manifest_data["id"]
      assert_equal "test-workflow", manifest_data["name"]
      assert_equal "description", manifest_data["description"]
      assert_equal project_dir, manifest_data["project_dir"]
    end
  end

  test 'deletes workflow' do
    Dir.mktmpdir do |tmp|
      project_dir = Pathname.new(tmp)
      workflow = create_workflow(project_dir: project_dir)

      assert Dir.entries("#{project_dir}/.ondemand/workflows/").include?("#{workflow.id}.yml")

      workflow.destroy!
      assert_not Dir.entries("#{project_dir}/.ondemand/workflows/").include?("#{workflow.id}.yml")
    end
  end

  test 'update workflow manifest file' do
    Dir.mktmpdir do |tmp|
      project_dir = Pathname.new(tmp)
      workflow = create_workflow(id: "test-#{Workflow.next_id}", project_dir: project_dir)

      name          = 'test-workflow-2'
      description   = 'my test workflow'
      test_attributes = { name: name, description: description }

      assert workflow.update(test_attributes)
      assert File.exist?(workflow.manifest_file)

      manifest_data = YAML.safe_load(File.read(workflow.manifest_file), permitted_classes: [Pathname], aliases: true)

      assert_equal workflow.id, manifest_data["id"]
      assert_equal name, manifest_data["name"]
      assert_equal description, manifest_data["description"]
      assert_equal project_dir, manifest_data["project_dir"]
    end
  end

  test 'update workflow only updates name, and description' do
    Dir.mktmpdir do |tmp|
      project_dir = Pathname.new(tmp)
      workflow = create_workflow(project_dir: project_dir)
      old_id = workflow.id

      assert workflow.update({ id: 'updated', name: 'updated', description: 'updated', project_dir: nil})
      assert_equal 'updated', workflow.name
      assert_equal 'updated', workflow.description
      assert_equal old_id, workflow.id
      assert_equal project_dir, workflow.project_dir
    end
  end

  def create_workflow(id: nil, name: 'test-workflow', description: 'description', project_dir: nil, launcher_ids: [], source_ids: [], target_ids: [])
    attrs = { name: name, id: id, description: description, project_dir: project_dir, launcher_ids: launcher_ids, source_ids: source_ids, target_ids: target_ids}
    workflow = Workflow.new(attrs)
    assert workflow.save

    workflow
  end
end
