require 'test_helper'

class DashboardControllerTest < ActionController::TestCase

  def setup
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys"))
  end

  def dropdown_list(title)
    css_select("li.dropdown[title='#{title}'] ul")
  end
  
  def dropdown_link(order)
    ".navbar-collapse > .nav li.dropdown:nth-of-type(#{order}) a"
  end

  # given a dropdown list, return the list items as an array of strings
  # with symbols for header or divider
  def dropdown_list_items(list)
    css_select(list, "li").map do |item|
      if item['class'] && item['class'].include?("divider")
        :divider
      elsif item['class'] && item['class'].include?("dropdown-header")
        { :header => item.text.strip }
      else
        item.text.strip
      end
    end
  end

  test "should create Jobs dropdown" do
    get :index

    dditems = dropdown_list_items(dropdown_list('Jobs'))
    assert dditems.any?, "dropdown list items not found"
    assert_equal ["Active Jobs", "My Jobs"], dditems
  end

  test "should create Files dropdown" do
    OodFilesApp.any_instance.stubs(:favorite_paths).returns([FavoritePath.new("/fs/scratch/efranz", title: "Scratch")])
    
    get :index

    dditems = dropdown_list_items(dropdown_list('Files'))
    assert dditems.any?, "dropdown list items not found"
    assert_equal [
      "Home Directory",
      "Scratch /fs/scratch/efranz"], dditems.map { |e| e.gsub(/\s+/, ' ')  }
  end

  test "should create Clusters dropdown with valid clusters that are alphabetically ordered by title" do
    OodAppkit.stubs(:clusters).returns(
      OodCore::Clusters.new([
        {id: :cluster1, metadata: {title: "Cluster B"}, login: {host: "host"}},
        {id: :cluster2, metadata: {title: "Cluster D"}, login: {host: "host"}},
        {id: :cluster3, metadata: {title: "Cluster C"}, login: {host: "host"}},
        {id: :cluster4, metadata: {title: "Cluster A"}, login: {host: "host"}},
        {id: :cluster5, metadata: {title: "Cluster NoLogin"}, login: nil},
        {id: :cluster6, metadata: {title: "Cluster NoAccess"}, login: {host: "host"}, acls: [{adapter: :group, groups: ["GROUP"]}]},
      ].map {|h| OodCore::Cluster.new(h)})
    )

    get :index

    dd = dropdown_list('Clusters')
    dditems = dropdown_list_items(dd)

    assert dditems.any?, "dropdown list items not found"

    assert_equal [
      "Cluster A Shell Access",
      "Cluster B Shell Access",
      "Cluster C Shell Access",
      "Cluster D Shell Access",
      "System Status"], dditems

    assert_select dd, "li a", "System Status" do |link|
      assert_equal "/apps/show/systemstatus", link.first['href'], "System Status link is incorrect"
    end
  end

  test "should create Interactive Apps dropdown" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_interactive_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))

    get :index

    dd = dropdown_list('Interactive Apps')
    dditems = dropdown_list_items(dd)
    assert dditems.any?, "dropdown list items not found"
    assert_equal [
      {header: "Apps"},
      "Jupyter Notebook",
      "Paraview",
      :divider,
      {header: "Desktops"},
      "Oakley Desktop"], dditems

    assert_select dd, "li a", "Oakley Desktop" do |link|
      assert_equal "/batch_connect/sys/bc_desktop/oakley/session_contexts/new", link.first['href'], "Desktops link is incorrect"
    end
  end

  test "should create My Interactive Apps link if Interactive Apps exist and not developer" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_interactive_apps"))
    Configuration.stubs(:app_development_enabled?).returns(false)
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))

    get :index
    assert_response :success
    assert_select "nav a[href='#{batch_connect_sessions_path}']", 1
  end

  test "should create My Interactive Apps link if no Interactive Apps and developer" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys"))
    Configuration.stubs(:app_development_enabled?).returns(true)
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))

    get :index
    assert_response :success
    assert_select "nav a[href='#{batch_connect_sessions_path}']", 1
  end

  test "should not create My Interactive Apps link if no Interactive Apps and not developer" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys"))
    Configuration.stubs(:app_development_enabled?).returns(false)
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))

    get :index
    assert_response :success
    assert_select "nav a[href='#{batch_connect_sessions_path}']", 0
  end

  test "should not create app menus if NavConfig.categories is empty and whitelist is enabled" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    NavConfig.stubs(:categories_whitelist?).returns(true)
    NavConfig.stubs(:categories).returns([])
    
    get :index
    assert_response :success
    assert_select ".navbar-collapse > .nav li.dropdown[title]", 0
  end

  test "should exclude gateway apps if NavConfig.categories is set to default and whitelist is enabled" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    NavConfig.stubs(:categories_whitelist?).returns(true)
    NavConfig.stubs(:categories).returns(["Files", "Jobs", "Clusters", "Interactive Apps"])

    get :index
    assert_response :success
    assert_select ".navbar-collapse > .nav li.dropdown[title='Gateway Apps']", 0
  end

  test "uses NavConfig.categories as sort order if whitelist is false" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    NavConfig.stubs(:categories_whitelist?).returns(false)
    NavConfig.stubs(:categories).returns(["Files", "Jobs", "Clusters", "Interactive Apps"])
    
    get :index
    assert_response :success
    assert_select ".navbar-collapse > .nav li.dropdown[title]", 5
    assert_select  dropdown_link(1), text: "Files"
    assert_select  dropdown_link(2), text: "Jobs"
    assert_select  dropdown_link(3), text: "Clusters"
    assert_select  dropdown_link(4), text: "Interactive Apps"
    assert_select  dropdown_link(5), text: "Gateway Apps"
  end

  test "verify default values for NavConfig" do
    refute NavConfig.categories_whitelist?
    assert NavConfig
  end

  test "display all app menus in alphabetical order if NavConfig.whitelist false & NavConfig.categories nil or []" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    NavConfig.stubs(:categories_whitelist?).returns(false)
    NavConfig.stubs(:categories).returns([])

    get :index
    assert_response :success
    assert_select ".navbar-collapse > .nav li.dropdown[title]", 5
    assert_select dropdown_link(1), text: "Clusters"
    assert_select dropdown_link(2), text: "Files"
    assert_select dropdown_link(3), text: "Gateway Apps"
    assert_select dropdown_link(4), text: "Interactive Apps"
    assert_select dropdown_link(5), text: "Jobs"
  end

  test "apps with no category should not appear in menu" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    NavConfig.stubs(:categories_whitelist?).returns(false)

    get :index

    assert_select ".navbar-collapse > .nav li.dropdown[title='System Installed Apps']", 0, 'Apps with no category should not appear in menus (thus System Installed Apps)'
  end
  
  test "should not create any empty links" do
    get :index

    assert_response :success
    assert_select "a[href='']", count: 0
  end
end
