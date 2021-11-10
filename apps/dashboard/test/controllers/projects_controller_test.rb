require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get projects_index_url
    assert_response :success
  end

  test "should get show" do
    get projects_show_url
    assert_response :success
  end

  test "should get destroy" do
    get projects_destroy_url
    assert_response :success
  end

  test "should get edit" do
    get projects_edit_url
    assert_response :success
  end

  test "should get submit" do
    get projects_submit_url
    assert_response :success
  end

  test "should get create" do
    get projects_create_url
    assert_response :success
  end

  test "should get new" do
    get projects_new_url
    assert_response :success
  end

end
