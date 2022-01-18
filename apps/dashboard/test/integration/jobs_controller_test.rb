require 'test_helper'

class JobsControllerTest < ActionDispatch::IntegrationTest

  def setup
    OodAppkit.stubs(:dataroot).returns(Rails.root.join('test/fixtures/jobs'))
    Configuration.stubs(:jobs_app_alpha?).returns(true)
    Rails.application.reload_routes!
  end

  test "should get index" do 
    get jobs_projects_path
    assert_response :success
  end

  test "should get new" do
    get new_jobs_project_path
    assert_response :success
  end

  test "should get destroy" do
    get jobs_project_path(:id)
    assert_response :success
  end

  test "should get edit" do
    get edit_jobs_project_path(:id)
    assert_response :success
  end

  test "safe to get with invalid dataroot" do
    OodAppkit.stubs(:dataroot).returns(Pathname.new('/dev/null'))
    get jobs_projects_path
    assert_response :success
  end

  test "makes the directory if it doesnt exist" do
    Dir.mktmpdir do |dir|
        OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))
        assert  !Dir.exist?("#{dir}/projects")

        get jobs_projects_path
        assert_response :success

        assert Dir.exist?("#{dir}/projects")
    end
  end
end
