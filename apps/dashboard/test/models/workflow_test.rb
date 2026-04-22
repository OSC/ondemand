# frozen_string_literal: true

require 'test_helper'

class WorkflowsTest < ActiveSupport::TestCase
  test 'create empty workflow' do
    workflow = Workflow.new

    assert_nil workflow.id
    assert_equal '', workflow.project_dir
    assert_nil workflow.name
    assert_nil workflow.description
    assert_nil workflow.created_at
    assert_equal [], workflow.launcher_ids
    assert_equal '0', workflow.sync_key_enabled
  end

  test 'create workflow validation' do
    Dir.mktmpdir do |tmp|
      # add error in workflow save if project_dir is not valid
      # workflow = Workflow.new({})
      # assert_not workflow.save
      # assert_equal 1, workflow.errors.size
      # assert_not workflow.errors[:name].empty?

      invalid_directory = tmp
      workflow = Workflow.new({ 
        name:         'test',
        project_dir:  invalid_directory.to_s,
        launcher_ids: ['sample']
      })
      # this step is done by the project
      Workflow.workflow_dir(invalid_directory).mkpath
      assert workflow.save
      assert_equal 0, workflow.errors.size
    end
  end

  test 'creates workflow defaults' do
    stub_du
    Dir.mktmpdir do |tmp|
      project_dir = Pathname.new(tmp)
      workflow = create_workflow(
        name:         'MyLocalName',
        description:  'MyLocalDescription',
        project_dir:  project_dir,
        launcher_ids: ['sample']
      )

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
      workflow = create_workflow(
        id:           workflow_id,
        name:         'MyLocalName',
        description:  'MyLocalDescription',
        project_dir:  project_dir,
        launcher_ids: ['sample']
      )

      assert workflow.errors.inspect
      assert Dir.entries("#{project_dir}/.ondemand/workflows").include?("#{workflow_id}.yml")
      assert_equal workflow_id,          workflow.id
      assert_equal 'MyLocalName',        workflow.name
      assert_equal 'MyLocalDescription', workflow.description
      assert_equal ['sample'],           workflow.launcher_ids
    end
  end

  test 'creates manifest file in .ondemand/workflows config directory' do
    Dir.mktmpdir do |tmp|
      project_dir = Pathname.new(tmp)
      workflow = create_workflow(
        name:         'test-workflow',
        id:           "test-#{Workflow.next_id}",
        project_dir:  project_dir,
        launcher_ids: ['sample'],
        sync_key_enabled: '1'
      )

      assert workflow.errors.inspect
      manifest_file = Pathname.new("#{project_dir}/.ondemand/workflows/#{workflow.id}.yml")
      assert_equal manifest_file, workflow.manifest_file
      assert File.file?(manifest_file)

      manifest_data = YAML.safe_load(File.read(manifest_file), permitted_classes: [Pathname], aliases: true)

      assert_equal workflow.id, manifest_data["id"]
      assert_equal "test-workflow", manifest_data["name"]
      assert_equal "description", manifest_data["description"]
      assert_equal project_dir.to_s, manifest_data["project_dir"]
      assert_equal '1', manifest_data['sync_key_enabled']
    end
  end

  test 'deletes workflow' do
    Dir.mktmpdir do |tmp|
      project_dir = Pathname.new(tmp)
      workflow = create_workflow(project_dir: project_dir, launcher_ids: ['sample'])

      assert Dir.entries("#{project_dir}/.ondemand/workflows/").include?("#{workflow.id}.yml")

      workflow.destroy!
      assert_not Dir.entries("#{project_dir}/.ondemand/workflows/").include?("#{workflow.id}.yml")
    end
  end

  test 'update workflow manifest file' do
    Dir.mktmpdir do |tmp|
      project_dir = Pathname.new(tmp)
      workflow = create_workflow(
        id:           "test-#{Workflow.next_id}",
        project_dir:  project_dir,
        launcher_ids: ['sample']
      )

      name            = 'test-workflow-2'
      description     = 'my test workflow'
      launchers       = ['sample1', 'sample2']
      test_attributes = { name: name, description: description, launcher_ids: launchers }

      assert workflow.update(test_attributes)
      assert File.exist?(workflow.manifest_file)

      manifest_data = YAML.safe_load(File.read(workflow.manifest_file), permitted_classes: [Pathname], aliases: true)

      assert_equal workflow.id, manifest_data["id"]
      assert_equal name,        manifest_data["name"]
      assert_equal description, manifest_data["description"]
      assert_equal project_dir.to_s, manifest_data["project_dir"]
      assert_equal launchers,   manifest_data["launcher_ids"]
    end
  end

  test 'update workflow only updates name, description, launchers, and sync_key_enabled' do
    Dir.mktmpdir do |tmp|
      project_dir = Pathname.new(tmp)
      workflow = create_workflow(project_dir: project_dir, launcher_ids:['sample'])
      old_id = workflow.id

      assert workflow.update({ 
        id: 'updated',
        name: 'updated',
        description: 'updated',
        project_dir: nil,
        launcher_ids: ['sample2'],
        sync_key_enabled: '1'
      })
      
      assert_equal 'updated',   workflow.name
      assert_equal 'updated',   workflow.description
      assert_equal old_id,      workflow.id
      assert_equal project_dir.to_s, workflow.project_dir
      assert_equal ['sample2'], workflow.launcher_ids
      assert_equal '1',         workflow.sync_key_enabled
    end
  end

  test 'Check if submit_launcher_params injects ood_workflow_sync_key only when sync_key_enabled is true' do
    fake_attr = Struct.new(:id, :opts)
    launcher = Object.new
    launcher.define_singleton_method(:cacheless_attributes) do
      [
        fake_attr.new('bc_num_hours', { value: '1' }),
        fake_attr.new('auto_queues',  { value: 'batch' })
      ]
    end

    workflow = Workflow.new
    without_key = workflow.submit_launcher_params(launcher, ['1234'], nil)
    assert_equal({'bc_num_hours' => '1', 'auto_queues' => 'batch', 'afterok' => ['1234'] }, without_key)
    assert_not without_key.key?('ood_workflow_sync_key')

    with_key = workflow.submit_launcher_params(launcher, ['1234'], 'abc123TOKEN')
    assert_equal({'bc_num_hours' => '1', 'auto_queues' => 'batch', 'afterok' => ['1234'], 'ood_workflow_sync_key' => 'abc123TOKEN'}, with_key)
  end

  def create_workflow(id: nil, name: 'test-workflow', description: 'description', project_dir: nil, launcher_ids: [], sync_key_enabled: '0')
    attrs = { name: name, id: id, description: description, project_dir: project_dir, launcher_ids: launcher_ids, sync_key_enabled: sync_key_enabled}
    workflow = Workflow.new(attrs)
    # this directory is usually created by the project
    Workflow.workflow_dir(project_dir).mkpath
    assert workflow.save, "failed to save workflow due to #{workflow.errors.full_messages}"

    workflow
  end
end
