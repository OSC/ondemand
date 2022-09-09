require 'test_helper'

class NavBarTest < ActiveSupport::TestCase

  def setup
    # Mock the sys installed applications
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
  end

  test "NavBar.items should return navigation template when nav_item is a string matching a static link" do
    nav_item = "all_apps"

    result = NavBar.items([nav_item])
    assert_equal 1,  result.size
    assert_equal "layouts/nav/all_apps",  result[0].partial_path
  end

  test "NavBar.items should return navigation link when nav_item is a string matching one app token" do
    nav_item = "sys/bc_jupyter"

    result = NavBar.items([nav_item])
    assert_equal 1,  result.size
    assert_equal "layouts/nav/link",  result[0].partial_path
    assert_equal "Jupyter Notebook",  result[0].title
    assert_equal "/batch_connect/sys/bc_jupyter/session_contexts/new",  result[0].url
  end

  test "NavBar.items should return navigation group when nav_item is a string matching multiple app tokens" do
    nav_item = "sys/bc_*"

    result = NavBar.items([nav_item])
    assert_equal 1,  result.size
    assert_equal "layouts/nav/group",  result[0].partial_path
    assert_equal "Apps",  result[0].title
    assert_equal 4,  result[0].apps.size
  end

  test "NavBar.items should return navigation group when nav_item is a string matching an sys application category" do
    nav_item = "Interactive Apps"

    result = NavBar.items([nav_item])
    assert_equal 1,  result.size
    assert_equal "layouts/nav/group",  result[0].partial_path
    assert_equal "Interactive Apps",  result[0].title
    assert_equal 4,  result[0].apps.size
  end

  test "NavBar.items should return navigation group when nav_item has links property" do
    nav_item = {
      title: "menu title",
      links: []
    }

    result = NavBar.items([nav_item])
    assert_equal 1,  result.size
    assert_equal "layouts/nav/group",  result[0].partial_path
    assert_equal "menu title",  result[0].title
  end

  test "NavBar.items should return navigation link when nav_item has url property" do
    nav_item = {
      title: "link title",
      url: "/path/test"
    }

    result = NavBar.items([nav_item])
    assert_equal 1,  result.size
    assert_equal "layouts/nav/link",  result[0].partial_path
    assert_equal "link title",  result[0].title
    assert_equal "/path/test",  result[0].url
  end

  test "NavBar.items should return navigation profile when nav_item has profile property" do
    nav_item = {
      title: "profile title",
      profile: "profile1"
    }
    expected_data_property = { method: 'post' }
    result = NavBar.items([nav_item])
    assert_equal 1,  result.size
    assert_equal "layouts/nav/link",  result[0].partial_path
    assert_equal "profile title",  result[0].title
    assert_equal "/settings?settings%5Bprofile%5D=profile1",  result[0].url
    assert_equal expected_data_property,  result[0].data
    assert_equal false,  result[0].new_tab?
  end

  test "NavBar.items should return navigation link when nav_item has app property" do
    nav_item = {
      apps: "sys/bc_jupyter"
    }

    result = NavBar.items([nav_item])
    assert_equal 1,  result.size
    assert_equal "layouts/nav/link",  result[0].partial_path
    assert_equal "Jupyter Notebook",  result[0].title
  end

  test "NavBar.items should return navigation link when nav_item has tokens property" do
    nav_item = {
      apps: ["sys/bc_jupyter"]
    }

    result = NavBar.items([nav_item])
    assert_equal 1,  result.size
    assert_equal "layouts/nav/link",  result[0].partial_path
    assert_equal "Jupyter Notebook",  result[0].title
  end

  test "NavBar should keep navigation order from configuration" do
    titles = (1..10).to_a.map{ |_| SecureRandom.uuid }
    config = titles.map{ |x| {title: x, links: []} }

    result = NavBar.items(config)
    assert_equal 10,  result.size
    titles.each_with_index do |title, index|
      assert_equal title,  result[index].title
    end
  end

  test "NavBar.items should return empty list when empty configuration provided" do
    assert_equal true,  NavBar.items([]).empty?
  end

  test "NavBar.items should discard invalid configuration items" do
    valid_item = {
      apps: "sys/bc_jupyter"
    }

    result = NavBar.items([stub(), valid_item, stub()])
    assert_equal 1,  result.size
    assert_equal "Jupyter Notebook",  result[0].title
  end

  test "Check supported static links" do
    NavBar::STATIC_LINKS.each do |name, template|
      assert_equal true,  [:all_apps, :featured_apps, :sessions, :log_out, :user].include?(name)
    end
  end

end