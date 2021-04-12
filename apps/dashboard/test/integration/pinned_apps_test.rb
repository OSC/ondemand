require 'html_helper'
require 'test_helper'

class PinnedAppsTest < ActionDispatch::IntegrationTest

  def setup
    Router.instance_variable_set('@pinned_apps', nil)
  end

  def teardown
    Router.instance_variable_set('@pinned_apps', nil)
  end

  test "should create Apps dropdown when pinned apps are available" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    Configuration.stubs(:pinned_apps).returns([
      'sys/bc_jupyter',
      'sys/bc_paraview',
      'sys/bc_desktop/owens',
      'sys/bc_desktop/doesnt_exist',
      'sys/pseudofun',
      'sys/should_get_filtered'
    ])

    get '/'

    dd = dropdown_list('Apps')
    dditems = dropdown_list_items(dd)
    assert dditems.any?, "dropdown list items not found"
    assert_equal [
      { header: I18n.t('dashboard.pinned_apps_title') },
      "Owens Desktop",
      "Jupyter Notebook",
      "Paraview",
      "PseudoFuN",
      :divider,
      "All Apps"
    ], dditems
  end

  test "should limit list of Pinned Apps in dropdown" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    Configuration.stubs(:pinned_apps).returns([
      'sys/bc_jupyter',
      'sys/bc_paraview',
      'sys/bc_desktop/owens',
      'sys/bc_desktop/doesnt_exist',
      'sys/pseudofun',
      'sys/should_get_filtered'
    ])
    Configuration.stubs(:pinned_apps_menu_length).returns(2)

    get '/'

    dd = dropdown_list('Apps')
    dditems = dropdown_list_items(dd)
    assert dditems.any?, "dropdown list items not found"
    assert_equal [
      { header: "Pinned Apps (showing 2 of 4)" },
      "Owens Desktop",
      "Jupyter Notebook",
      :divider,
      "All Apps"
    ], dditems
  end

  test "should create Pinned app icons when pinned apps are available" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    Configuration.stubs(:pinned_apps).returns([
      'sys/bc_jupyter',
      'sys/bc_paraview',
      'sys/bc_desktop/owens',
      'sys/bc_desktop/doesnt_exist',
      'sys/pseudofun',
      'sys/should_get_filtered'
    ])

    get '/'

    assert_response :success

    assert_select 'a.app-card', 4
    assert_select "a.app-card[href='/batch_connect/sys/bc_jupyter/session_contexts/new']", 1
    assert_select "a.app-card[href='/batch_connect/sys/bc_paraview/session_contexts/new']", 1
    assert_select "a.app-card[href='/apps/show/pseudofun']", 1
    assert_select "a.app-card[href='/batch_connect/sys/bc_desktop/owens/session_contexts/new']", 1
  end

  test "does not create pinned apps when no configuration" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    Configuration.stubs(:pinned_apps).returns([])

    get '/'

    assert_response :success

    assert_select 'a.app-card', 0
  end

  test "shows pinned apps when MOTD is present" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    Configuration.stubs(:pinned_apps).returns([
      'sys/bc_jupyter',
      'sys/bc_paraview',
      'sys/bc_desktop/owens',
      'sys/bc_desktop/doesnt_exist',
      'sys/pseudofun',
      'sys/should_get_filtered'
    ])

    env = {
      MOTD_FORMAT: 'osc',
      MOTD_PATH: Rails.root.join("test/fixtures/files/motd_valid").to_s
    }

    with_modified_env(env) do
      get '/'
    end

    assert_select 'a.app-card', 4
    assert_select "a.app-card[href='/batch_connect/sys/bc_jupyter/session_contexts/new']", 1
    assert_select "a.app-card[href='/batch_connect/sys/bc_paraview/session_contexts/new']", 1
    assert_select "a.app-card[href='/apps/show/pseudofun']", 1
    assert_select "a.app-card[href='/batch_connect/sys/bc_desktop/owens/session_contexts/new']", 1

    assert_select 'h3', 2
    assert_equal I18n.t('dashboard.motd_title'), css_select('h3')[1].text

    assert_select "div[class='motd']", 3
    assert_select "h4[class='motd_title']", 3
  end

  test "shows pinned apps when XDMOD is present" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    Configuration.stubs(:pinned_apps).returns([
      'sys/bc_jupyter',
      'sys/bc_paraview',
      'sys/bc_desktop/owens',
      'sys/bc_desktop/doesnt_exist',
      'sys/pseudofun',
      'sys/should_get_filtered'
    ])

    env = {
      #this is going to fail, but that's OK - the widets will still appear
      OOD_XDMOD_HOST: "http://localhost"
    }

    with_modified_env(env) do
      get '/'
    end

    assert_select 'a.app-card', 4
    assert_select "a.app-card[href='/batch_connect/sys/bc_jupyter/session_contexts/new']", 1
    assert_select "a.app-card[href='/batch_connect/sys/bc_paraview/session_contexts/new']", 1
    assert_select "a.app-card[href='/apps/show/pseudofun']", 1
    assert_select "a.app-card[href='/batch_connect/sys/bc_desktop/owens/session_contexts/new']", 1

    assert_select "div[class='xdmod']", 2
    assert_select "div[id='jobsEfficiencyReportPanelDiv']", 1
    assert_select "div[id='coreHoursEfficiencyReportPanelDiv']", 1
    assert_select "div[id='jobsPanelDiv']", 1
  end

  test "shows pinned apps when both MOTD and XDMOD is present" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    Configuration.stubs(:pinned_apps).returns([
      'sys/bc_jupyter',
      'sys/bc_paraview',
      'sys/bc_desktop/owens',
      'sys/bc_desktop/doesnt_exist',
      'sys/pseudofun',
      'sys/should_get_filtered'
    ])

    env = {
      MOTD_FORMAT: 'osc',
      MOTD_PATH: Rails.root.join("test/fixtures/files/motd_valid").to_s,
      #this is going to fail, but that's OK - the widets will still appear
      OOD_XDMOD_HOST: "http://localhost"
    }

    with_modified_env(env) do
      get '/'
    end

    assert_select 'a.app-card', 4
    assert_select "a.app-card[href='/batch_connect/sys/bc_jupyter/session_contexts/new']", 1
    assert_select "a.app-card[href='/batch_connect/sys/bc_paraview/session_contexts/new']", 1
    assert_select "a.app-card[href='/apps/show/pseudofun']", 1
    assert_select "a.app-card[href='/batch_connect/sys/bc_desktop/owens/session_contexts/new']", 1

    assert_select 'h3', 2
    assert_equal I18n.t('dashboard.motd_title'), css_select('h3')[1].text

    assert_select "div[class='motd']", 3
    assert_select "h4[class='motd_title']", 3

    assert_select "div[class='xdmod']", 2
    assert_select "div[id='jobsEfficiencyReportPanelDiv']", 1
    assert_select "div[id='coreHoursEfficiencyReportPanelDiv']", 1
    assert_select "div[id='jobsPanelDiv']", 1
  end

  test "still shows MOTD when no pinned apps" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    Configuration.stubs(:pinned_apps).returns([])

    env = {
      MOTD_FORMAT: 'osc',
      MOTD_PATH: Rails.root.join("test/fixtures/files/motd_valid").to_s
    }

    with_modified_env(env) do
      get '/'
    end

    assert_select 'h3', 1
    assert_equal I18n.t('dashboard.motd_title'), css_select('h3').text

    assert_select "div[class='motd']", 3
    assert_select "h4[class='motd_title']", 3
  end

  test "still shows XDMOD when no pinned apps" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    Configuration.stubs(:pinned_apps).returns([])

    env = {
      #this is going to fail, but that's OK - the widets will still appear
      OOD_XDMOD_HOST: "http://localhost"
    }

    with_modified_env(env) do
      get '/'
    end

    assert_select "div[class='xdmod']", 2
    assert_select "div[id='jobsEfficiencyReportPanelDiv']", 1
    assert_select "div[id='coreHoursEfficiencyReportPanelDiv']", 1
    assert_select "div[id='jobsPanelDiv']", 1
  end

  test "still shows MOTD and XDMOD when no pinned apps" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    Configuration.stubs(:pinned_apps).returns([])

    env = {
      MOTD_FORMAT: 'osc',
      MOTD_PATH: Rails.root.join("test/fixtures/files/motd_valid").to_s,
      #this is going to fail, but that's OK - the widets will still appear
      OOD_XDMOD_HOST: "http://localhost"
    }

    with_modified_env(env) do
      get '/'
    end

    assert_select 'h3', 1
    assert_equal I18n.t('dashboard.motd_title'), css_select('h3').text

    assert_select "div[class='motd']", 3
    assert_select "h4[class='motd_title']", 3

    assert_select "div[class='xdmod']", 2
    assert_select "div[id='jobsEfficiencyReportPanelDiv']", 1
    assert_select "div[id='coreHoursEfficiencyReportPanelDiv']", 1
    assert_select "div[id='jobsPanelDiv']", 1
  end

  test "groups the apps by categories" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    Configuration.stubs(:pinned_apps).returns([
      'sys/bc_jupyter',
      'sys/bc_paraview',
      'sys/pseudofun',
    ])
    Configuration.stubs(:pinned_apps_group_by).returns("original_category")

    env = {}

    with_modified_env(env) do
      get '/'
    end

    assert_select "h4[class='apps-section-header-blue']", 2
    assert_select "a.app-card", 3
    assert_equal "Gateway Apps", css_select("h4[class='apps-section-header-blue']")[0].text
    assert_equal "Interactive Apps", css_select("h4[class='apps-section-header-blue']")[1].text
  end

  test "groups the apps by sub-categories" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    Configuration.stubs(:pinned_apps).returns([
      'sys/bc_jupyter',
      'sys/bc_paraview',
      'sys/pseudofun',
    ])
    Configuration.stubs(:pinned_apps_group_by).returns("original_subcategory")

    env = {}

    with_modified_env(env) do
      get '/'
    end

    assert_select "h4[class='apps-section-header-blue']", 2
    assert_select "a.app-card", 3
    assert_equal "Apps", css_select("h4[class='apps-section-header-blue']")[0].text
    assert_equal "Biomedical Informatics", css_select("h4[class='apps-section-header-blue']")[1].text
  end

  test "still shows ungroupable apps" do
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    Configuration.stubs(:pinned_apps).returns([
      'sys/bc_jupyter',
      'sys/bc_paraview',
      'sys/pseudofun',
    ])
    Configuration.stubs(:pinned_apps_group_by).returns("some_unknown_field")

    env = {}

    with_modified_env(env) do
      get '/'
    end

    assert_select "h4[class='apps-section-header-blue']", 1
    assert_select "a.app-card", 3
    assert_equal I18n.t('dashboard.not_grouped'), css_select("h4[class='apps-section-header-blue']")[0].text
  end
end
