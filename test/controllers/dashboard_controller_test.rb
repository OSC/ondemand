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

  def assert_header(item, title)
    assert_equal "dropdown-header", item['class'], "li was supposed to be a dropdown-header"
    assert_equal title, item.text.strip
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
      assert_select items[1], "a", "System Status" do |item|
        assert_equal "/apps/show/systemstatus", item.first['href']
      end

    end
  end

  test "should create Interactive Apps dropdown" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_interactive_apps"))

    get :index

    assert_select "li.dropdown[title='Interactive Apps'] li" do |items|
      assert_select items[0], "a", "Interactive Sessions", "need to add Active Sessions to each menu that has batch connect apps"
      assert_divider items[1]

      # Apps and Desktops
      assert_header items[2], "Apps"
      assert_select items[3], "a", "Jupyter", "Jupyter link not in menu"
      assert_select items[4], "a", "Paraview", "Paraview link not in menu"
      assert_divider items[5]
      assert_header items[6], "Desktops"
      assert_select items[7], "a", "Desktops", "Desktops link not in menu" do |item|
        assert_equal "/apps/show/bc_desktop", item.first['href']
      end
    end

    SysRouter.unstub(:base_path)
  end
end
