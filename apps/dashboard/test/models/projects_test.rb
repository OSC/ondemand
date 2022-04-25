require 'test_helper'

class ProjectsTest < ActiveSupport::TestCase

  test "creates project" do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      attrs = { name: 'test project' }
      project = Project.new(attrs)
      project.save(attrs)

      assert Dir.entries("#{projects_path}/projects").include?("test_project")
    end
  end

  test "creates .ondemand configuration directory" do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      attrs = { name: 'test project' }
      project = Project.new(attrs)
      project.save(attrs)

      dot_ondemand_path = Pathname.new("#{projects_path}/projects/#{project.directory}")

      assert Dir.entries(dot_ondemand_path).include?(".ondemand")
    end
  end

  test "creates manifest.yml in .ondemand config directory" do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      attrs = { name: 'test project'}
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

  test "deletes project" do
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

  test "update project manifest.yml file" do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      attrs = { name: 'test project' }
      project = Project.new(attrs)
      project.save(attrs)

      name          = 'galaxies and galaxies'
      description   = 'a view into the past'
      icon          = 'fa://abell_1689'

      test_attributes = {name: name, description: description, icon: icon }

      expected_manifest_yml = <<~HEREDOC
        ---
        name: galaxies and galaxies
        description: a view into the past
        icon: fa://abell_1689
      HEREDOC

      project.update(test_attributes)

      assert_equal expected_manifest_yml, File.read("#{project.manifest_path}")
    end
  end
end
