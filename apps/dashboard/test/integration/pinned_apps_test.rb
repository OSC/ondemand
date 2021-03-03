require 'html_helper'
require 'test_helper'

class PinnedAppsTest < ActionDispatch::IntegrationTest

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
      { header: "Pinned Apps" },
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

    assert_select 'a.thumbnail.app', 4
    assert_select "a.thumbnail.app[href='/batch_connect/sys/bc_jupyter/session_contexts/new']", 1
    assert_select "a.thumbnail.app[href='/batch_connect/sys/bc_paraview/session_contexts/new']", 1
    assert_select "a.thumbnail.app[href='/apps/show/pseudofun']", 1
    assert_select "a.thumbnail.app[href='/batch_connect/sys/bc_desktop/owens/session_contexts/new']", 1
  end
end