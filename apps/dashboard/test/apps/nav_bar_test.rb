require 'test_helper'

class NavBarTest < ActiveSupport::TestCase

  test "NavBar.infer_type should infer :nav_menu when nav_item has links property" do
    nav_item = {
      title: "test",
      links: []
    }

    assert_equal :nav_menu,  NavBar.send(:infer_type, nav_item)
  end

  test "NavBar.infer_type should infer :nav_link when nav_item has url property" do
    nav_item = {
      title: "test",
      url: "/test"
    }

    assert_equal :nav_link,  NavBar.send(:infer_type, nav_item)
  end

  test "NavBar.infer_type should infer :nav_link when nav_item has profile property" do
    nav_item = {
      title: "test",
      profile: "profile1"
    }

    assert_equal :nav_link,  NavBar.send(:infer_type, nav_item)
  end

  test "NavBar.infer_type should infer :nav_app when nav_item has app property" do
    nav_item = {
      title: "test",
      app: "sys/rstudio"
    }

    assert_equal :nav_app,  NavBar.send(:infer_type, nav_item)
  end

  test "NavBar.infer_type should infer :nav_app when nav_item has tokens property" do
    nav_item = {
      title: "test",
      tokens: ["sys/rstudio"]
    }

    assert_equal :nav_app,  NavBar.send(:infer_type, nav_item)
  end

  test "NavBar.infer_type should infer :nav_template when nav_item has template property" do
    nav_item = {
      title: "test",
      template: "all_apps"
    }

    assert_equal :nav_template,  NavBar.send(:infer_type, nav_item)
  end

  test "NavBar.infer_type should infer :nav_divider when nav_item has no recognizable properties" do
    nav_item = {
      new_property: "test",
      other: "all_apps"
    }
    assert_equal :nav_divider,  NavBar.send(:infer_type, nav_item)
  end

  test "NavBar.infer_type should infer :nav_divider when nav_item has no properties" do
    assert_equal :nav_divider,  NavBar.send(:infer_type, { })
  end

  test "NavBar.from_config should delegate to NavBar.infer_type and create a NavBar::NavItem for each nav_item in the array" do
    menu_item = {
      title: "test",
      links: []
    }
    app_item = {
      title: "test",
      app: "sys/rstudio"
    }

    NavBar.expects(:infer_type).with(menu_item).returns(:nav_menu)
    NavBar::NavItem.expects(:new).with(:nav_menu, menu_item)
    NavBar.expects(:infer_type).with(app_item).returns(:nav_app)
    NavBar::NavItem.expects(:new).with(:nav_app, app_item)
    NavBar.from_config([menu_item, app_item])
  end

  test "NavBar.from_config should use type property when provided in configuration" do
    menu_item = {
      type: "nav_link",
      title: "test",
    }
    app_item = {
      title: "test",
      app: "sys/rstudio"
    }

    NavBar::NavItem.expects(:new).with(:nav_link, menu_item)
    NavBar.expects(:infer_type).with(menu_item).never
    NavBar.expects(:infer_type).with(app_item).returns(:nav_app)
    NavBar::NavItem.expects(:new).with(:nav_app, app_item)

    NavBar.from_config([menu_item, app_item])
  end

  test "NavBar should keep navigation order from configuration" do
    titles = (1..10).to_a.map{ |_| SecureRandom.uuid }
    config = titles.map{ |x| {title: x} }

    result = NavBar.from_config(config)
    assert_equal 10,  result.nav_items.size
    titles.each_with_index do |title, index|
      assert_equal title,  result.nav_items[index].title
    end
  end

  test "empty? should be false when NavBar has items" do
    assert_equal false,  NavBar.new(nav_items: [stub()]).empty?
  end

  test "empty? should be true when NavBar is empty" do
    assert_equal true,  NavBar.new(nav_items: []).empty?
  end

end