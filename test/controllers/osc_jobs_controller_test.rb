require 'test_helper'

class OscJobsControllerTest < ActionController::TestCase
  setup do
    @osc_job = osc_jobs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:osc_jobs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create osc_job" do
    assert_difference('OscJob.count') do
      post :create, osc_job: { batch_host: @osc_job.batch_host, name: @osc_job.name }
    end

    assert_redirected_to osc_job_path(assigns(:osc_job))
  end

  test "should show osc_job" do
    get :show, id: @osc_job
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @osc_job
    assert_response :success
  end

  test "should update osc_job" do
    patch :update, id: @osc_job, osc_job: { batch_host: @osc_job.batch_host, name: @osc_job.name }
    assert_redirected_to osc_job_path(assigns(:osc_job))
  end

  test "should destroy osc_job" do
    assert_difference('OscJob.count', -1) do
      delete :destroy, id: @osc_job
    end

    assert_redirected_to osc_jobs_path
  end
end
