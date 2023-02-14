require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest

  def setup
    OodAppkit.stubs(:dataroot).returns(Rails.root.join('test/fixtures/projects'))
    Configuration.stubs(:jobs_app_alpha?).returns(true)
    Rails.application.reload_routes!
  end

  test "should get index" do 
    get projects_path
    assert_response :success
  end

  test "should get new" do
    get new_project_path
    assert_response :success
  end

  test 'should redirect when it cannot find the project' do
    get project_path('wont_find_this')
    assert_response :redirect
  end

  test "should get edit" do
    # I think the project needs to exist to edit, :dir is missing in template
    Dir.mktmpdir do |dir|
      Project.stubs(dir).returns(Pathname.new("#{dir}/projects/project_1"))
      assert  !Dir.exist?("#{dir}/projects/project_1")

      get edit_project_path(dir)
      assert_response :success
    end
  end

  test "safe to get with invalid dataroot" do
    OodAppkit.stubs(:dataroot).returns(Pathname.new('/dev/null'))
    get projects_path
    assert_response :success
  end

  test "makes the directory if it doesnt exist" do
    Dir.mktmpdir do |dir|
        OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))
        assert  !Dir.exist?("#{dir}/projects")

        get projects_path
        assert_response :success

        assert Dir.exist?("#{dir}/projects")
    end
  end
end
