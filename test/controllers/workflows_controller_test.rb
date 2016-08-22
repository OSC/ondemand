require 'test_helper'

class WorkflowsControllerTest < ActionController::TestCase
  setup do
    @workflow = workflows(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:workflows)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  # TODO Fix StagingTemplateDirMissing
  #test "should create workflow" do
  #  assert_difference('Workflow.count') do
  #    post :create, workflow: { batch_host: @workflow.batch_host, name: @workflow.name }
  #  end
  #
  #  assert_redirected_to osc_job_path(assigns(:workflow))
  #end

  test "should show workflow" do
    get :show, id: @workflow
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @workflow
    assert_response :success
  end

  # TODO Fix undefined method 'osc_job_path'
  #test "should update workflow" do
  #  patch :update, id: @workflow, workflow: { batch_host: @workflow.batch_host, name: @workflow.name }
  #  assert_redirected_to osc_job_path(assigns(:workflow))
  #end

  test "should destroy workflow" do
    assert_difference('Workflow.count', -1) do
      delete :destroy, id: @workflow
    end

    assert_redirected_to workflows_path
  end
end
