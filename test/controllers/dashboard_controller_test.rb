require 'test_helper'

class DashboardControllerTest < ActionController::TestCase

  def setup
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys"))
    OodFilesApp.any_instance.stubs(:favorite_paths).returns([Pathname.new("/fs/scratch/efranz")])
    ApplicationHelper.stubs(:login_clusters).returns([])
  end

  def teardown
    SysRouter.unstub(:base_path)
    OodFilesApp.any_instance.unstub(:favorite_paths)
    ApplicationHelper.unstub(:login_clusters)
  end

  def assert_divider(item)
    assert_equal "divider", item['class'], "li was supposed to be a divider"
  end

  test "should create Jobs dropdown" do

    get :index

    assert_select "li.dropdown[title='Jobs'] li" do |items|
      assert_select items[0], "a", "Active Jobs"
      assert_select items[1], "a", "My Jobs"
    end
  end

  test "should create Files dropdown" do
    get :index

    assert_select "li.dropdown[title='Files'] li" do |items|
      assert_select items[0], "a", "Home Directory"
      assert_divider items[1]
      assert_select items[2], "a", "/fs/scratch/efranz"
    end
  end

  test "should create Clusters dropdown" do
    get :index

    assert_select "li.dropdown[title='Clusters'] li" do |items|
      assert_select items[0], "a", "Shell Access"
      assert_select items[1], "a", "System Status"
    end
  end
end
