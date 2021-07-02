
require 'test_helper'

class FilesAppTest < ActionDispatch::IntegrationTest

  test "Files app displays terminal button when configuration is set to true" do
    Configuration.stubs(:files_app_can_launch_terminal?).returns(true)

    get '/files/fs/tmp'

    assert_select "div[id='shell-wrapper']", 1
  end

  test "Files app does not displays terminal button when configuration is set to false" do
    Configuration.stubs(:files_app_can_launch_terminal?).returns(false)

    get '/files/fs/tmp'

    assert_select "div[id='shell-wrapper']", 0
  end
end