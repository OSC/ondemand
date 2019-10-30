require 'test_helper'

class FileManagerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get file_manager_index_url
    assert_response :success
  end

  test "should get show" do
    get file_manager_show_url
    assert_response :success
  end

  test "should get copy" do
    get file_manager_copy_url
    assert_response :success
  end

  test "should get move" do
    get file_manager_move_url
    assert_response :success
  end

  test "should get rename" do
    get file_manager_rename_url
    assert_response :success
  end

  test "should get delete" do
    get file_manager_delete_url
    assert_response :success
  end

  test "should get download" do
    get file_manager_download_url
    assert_response :success
  end

  test "should get upload" do
    get file_manager_upload_url
    assert_response :success
  end

end
