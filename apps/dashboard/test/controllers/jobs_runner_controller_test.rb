require 'test_helper'

class JobsRunnerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get jobs_runner_index_url
    assert_response :success
  end

  test "should get new" do
    get jobs_runner_new_url
    assert_response :success
  end

  test "should get create" do
    get jobs_runner_create_url
    assert_response :success
  end

  test "should get destroy" do
    get jobs_runner_destroy_url
    assert_response :success
  end

  test "should get edit" do
    get jobs_runner_edit_url
    assert_response :success
  end

  test "should get update" do
    get jobs_runner_update_url
    assert_response :success
  end

  test "should get submit" do
    get jobs_runner_submit_url
    assert_response :success
  end

end
