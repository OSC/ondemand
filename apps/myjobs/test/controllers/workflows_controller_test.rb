# frozen_string_literal: true

require 'test_helper'

class WorkflowsControllerTest < ActionController::TestCase
  setup do
    @workflow = workflows(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:workflows)
    assert_select 'div.alert.alert-warning[role=alert]', /deprecated/
    assert_select 'div.alert.alert-warning a[href=?]', OodAppkit.dashboard.url.join('projects').to_s, text: 'Project Manager'
  end

  test 'should get new' do
    get :new
    assert_response :success
    assert_select 'div.alert.alert-warning[role=alert]', /deprecated/
  end

  # test "should create workflow" do
  #   assert_difference('Workflow.count') do
  #     post :create, workflow: { batch_host: @workflow.batch_host, name: @workflow.name, staging_template_dir: '/tmp' }
  #   end

  #   assert_redirected_to workflows_path
  # end

  test 'should show workflow' do
    get :show, params: { id: @workflow }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @workflow }
    assert_response :success
  end

  test 'should update workflow' do
    patch :update, params: { id: @workflow, workflow: { batch_host: @workflow.batch_host, name: @workflow.name } }
    assert_redirected_to workflows_path
  end

  test 'should destroy workflow' do
    assert_difference('Workflow.count', -1) do
      delete :destroy, params: { id: @workflow }
    end

    assert_redirected_to workflows_path
  end
end
