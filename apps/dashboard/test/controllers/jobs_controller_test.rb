require 'test_helper'

class JobsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get jobs_index_url
    assert_response :success
  end

  test "should get new" do
    get jobs_new_url
    assert_response :success
  end

  test "should get create" do
    get jobs_create_url
    assert_response :success
  end

  test "should get destroy" do
    get jobs_destroy_url
    assert_response :success
  end

  test "should get edit" do
    get jobs_edit_url
    assert_response :success
  end

  test "should get update" do
    get jobs_update_url
    assert_response :success
  end

  test "should get submit" do
    get jobs_submit_url
    assert_response :success
  end

end
