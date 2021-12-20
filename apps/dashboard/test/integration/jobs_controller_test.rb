require 'test_helper'

class JobsControllerTest < ActionDispatch::IntegrationTest

  def setup
    Jobs::Project.stubs(:base_path).returns(Rails.root.join('test/fixtures/integration/jobs/projects'))
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
end
