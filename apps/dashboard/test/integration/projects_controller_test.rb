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

  test 'should redirect from edit when it cannot find the project' do
    Dir.mktmpdir do |dir|
      OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))
      assert !Dir.exist?("#{dir}/projects/1")

      get edit_project_path('1')
      assert_response :redirect
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
      assert !Dir.exist?("#{dir}/projects")

      get projects_path
      assert_response :success

      assert Dir.exist?("#{dir}/projects")
    end
  end
end
