require 'test_helper'

class RouterTest < ActiveSupport::TestCase

  UserDouble = Struct.new(:name)
  
  def setup
    Router.instance_variable_set('@pinned_apps', nil)
    Router.instance_variable_set('@sys_apps', nil)
    Router.instance_variable_set('@dev_apps', nil)
    Router.instance_variable_set('@usr_apps', nil)
    Router.instance_variable_set('@apps', nil)
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    OodSupport::Process.stubs(:user).returns(UserDouble.new('me'))
    FileUtils.chmod 0000, 'test/fixtures/usr/cant_see/'

    UsrRouter.stubs(:base_path).with(:owner => "me").returns(Pathname.new("test/fixtures/usr/me"))
    UsrRouter.stubs(:base_path).with(:owner => 'shared').returns(Pathname.new("test/fixtures/usr/shared"))
    UsrRouter.stubs(:base_path).with(:owner => 'cant_see').returns(Pathname.new("test/fixtures/usr/cant_see"))
    UsrRouter.stubs(:owners).returns(['me', 'shared', 'cant_see'])
  end

  def teardown
    FileUtils.chmod 0755, 'test/fixtures/usr/cant_see/'
  end

  test "all apps apis return at least empty arrays" do
    UsrRouter.stubs(:base_path).returns(Pathname.new("/dev/null"))
    assert_equal [], Router.sys_apps
    assert_equal [], Router.dev_apps
    assert_equal [], Router.usr_apps
    assert_equal [], Router.apps
  end

  test "all apps apis return correct apps" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    sys_apps = [
      "sys/activejobs",
      "sys/bc_desktop", # just the main app!
      "sys/bc_jupyter",
      "sys/bc_paraview",
      "sys/dashboard",
      "sys/file-editor",
      "sys/files",
      "sys/myjobs",
      "sys/pseudofun",
      "sys/shell",
      "sys/systemstatus"
    ]

    dev_apps = sys_apps.map { |app| "dev/#{app.split("/")[1]}"}
    usr_apps = ["usr/me/my_shared_app", "usr/shared/bc_with_subapps", "usr/shared/bc_app"]

    assert_equal sys_apps.to_set, Router.sys_apps.map { |app| app.token }.to_set
    assert_equal dev_apps.to_set, Router.dev_apps.map { |app| app.token }.to_set
    assert_equal usr_apps.to_set, Router.usr_apps.map { |app| app.token }.to_set
    assert_equal (sys_apps + usr_apps + dev_apps).to_set, Router.apps.map { |app| app.token }.to_set
  end

  test "pinned apps with specific dev apps" do
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    real_apps = [
      'dev/bc_jupyter',
      'dev/bc_paraview',
      'dev/bc_desktop/owens',
      'dev/pseudofun'
    ]
    Configuration.stubs(:pinned_apps).returns(real_apps + [
      'sys/bc_desktop/doesnt_exist',
      'sys/should_get_filtered'
    ])
    
    assert_equal real_apps.to_set, Router.pinned_apps.map { |app| app.token }.to_set
  end

  test "pinned apps with specific sys apps" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    real_apps = [
      'sys/bc_jupyter',
      'sys/bc_paraview',
      'sys/bc_desktop/owens',
      'sys/pseudofun'
    ]

    Configuration.stubs(:pinned_apps).returns(real_apps + [
      'sys/bc_desktop/doesnt_exist',
      'sys/should_get_filtered'
    ])
    
    assert_equal real_apps.to_set, Router.pinned_apps.map { |app| app.token }.to_set
  end

  test "pinned apps with wildcarded sys apps" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))

    all_apps = [
      "sys/activejobs",
      "sys/bc_desktop/oakley", # picks up sub-apps instead of the main app
      "sys/bc_desktop/owens",
      "sys/bc_jupyter",
      "sys/bc_paraview",
      "sys/dashboard",
      "sys/file-editor",
      "sys/files",
      "sys/myjobs",
      "sys/pseudofun",
      "sys/shell",
      "sys/systemstatus"
    ]
    Configuration.stubs(:pinned_apps).returns(['sys/*'])
    
    assert_equal all_apps.to_set, Router.pinned_apps.map { |app| app.token }.to_set
  end

  test "pinned apps with wildcarded sys sub apps" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    apps = [
      "sys/bc_desktop/oakley",
      "sys/bc_desktop/owens",
      "sys/bc_jupyter",
      "sys/pseudofun"
    ]

    Configuration.stubs(:pinned_apps).returns([
      "sys/bc_desktop/*",
      "sys/bc_jupyter",
      "sys/pseudofun"
    ])
    
    assert_equal apps.to_set, Router.pinned_apps.map { |app| app.token }.to_set
  end

  test "pinned apps with specific usr apps" do
    UsrRouter.stubs(:base_path).with(:owner => "me").returns(Pathname.new("test/fixtures/usr/me"))
    UsrRouter.stubs(:base_path).with(:owner => 'shared').returns(Pathname.new("test/fixtures/usr/shared"))
    UsrRouter.stubs(:base_path).with(:owner => 'cant_see').returns(Pathname.new("test/fixtures/usr/cant_see"))
    UsrRouter.stubs(:owners).returns(['me', 'shared', 'cant_see'])

    real_apps = [
      'usr/shared/bc_with_subapps/owens',
      'usr/me/my_shared_app',
    ]

    Configuration.stubs(:pinned_apps).returns(real_apps + [
      'usr/doesnt_exist/some_app',
      'usr/should_get_filtered',
      'usr/cant_see/app_one',
      'usr/cant_see/app_two',
    ])

    assert_equal real_apps.to_set, Router.pinned_apps.map { |app| app.token }.to_set
  end

  test "pinned apps with wildcarded usr apps" do
    apps = [
      'usr/shared/bc_with_subapps/oakley',
      'usr/shared/bc_with_subapps/owens',
      'usr/shared/bc_app',
      'usr/me/my_shared_app'
    ]

    Configuration.stubs(:pinned_apps).returns([
      'usr/shared/*',
      'usr/me/*',
      'usr/cant_see/*',
      'usr/doesnt_exist/some_app',
      'usr/should_get_filtered'
    ])

    assert_equal apps.to_set, Router.pinned_apps.map { |app| app.token }.to_set
  end

  test "pinned apps with wildcarded usr sub apps apps" do
    apps = [
      'usr/shared/bc_with_subapps/oakley',
      'usr/shared/bc_with_subapps/owens',
      'usr/me/my_shared_app'
    ]

    Configuration.stubs(:pinned_apps).returns([
      'usr/shared/bc_with_subapps/*', # subapps/* here. usr/shared/bc_app not included
      'usr/me/*',
      'usr/cant_see/*',
      'usr/doesnt_exist/some_app',
      'usr/should_get_filtered'
    ])

    assert_equal apps.to_set, Router.pinned_apps.map { |app| app.token }.to_set
  end

  test "pinned apps with usr sys and dev apps" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_interactive_apps"))

    apps = [  
      "usr/shared/bc_with_subapps/oakley", 
      "usr/shared/bc_with_subapps/owens", 
      "usr/me/my_shared_app", 
      "sys/bc_paraview", 
      "sys/bc_desktop/oakley", 
      "sys/bc_desktop/owens", 
      "sys/bc_jupyter", 
      "sys/pseudofun", 
      "dev/activejobs", 
      "dev/bc_desktop/oakley",  # dev/* gives the 1 subapp, not the main app
      "dev/bc_jupyter", 
      "dev/bc_paraview", 
      "dev/dashboard", 
      "dev/file-editor", 
      "dev/files", 
      "dev/myjobs", 
      "dev/shell", 
      "dev/systemstatus"
    ]

    Configuration.stubs(:pinned_apps).returns([
      'usr/shared/bc_with_subapps/*',
      'usr/me/*',
      'usr/shared/cant_see',
      'sys/bc_paraview',
      'sys/bc_desktop/*',
      'sys/bc_jupyter',
      'sys/pseudofun',
      'dev/*'
    ])

    assert_equal apps.to_set, Router.pinned_apps.map { |app| app.token }.to_set
  end

  test "pinned apps wont duplicate entries" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    Configuration.stubs(:pinned_apps).returns(['sys/bc_jupyter', 'sys/*', 'sys/bc_jupyter', 'sys/pseudofun'])

    all_apps = [
      "sys/bc_jupyter",
      "sys/activejobs",
      "sys/bc_desktop/oakley", # picks up sub-apps instead of the main app
      "sys/bc_desktop/owens",
      "sys/bc_paraview",
      "sys/dashboard",
      "sys/file-editor",
      "sys/files",
      "sys/myjobs",
      "sys/pseudofun",
      "sys/shell",
      "sys/systemstatus"
    ]

    assert_equal all_apps.size, Router.pinned_apps.size
    assert_equal all_apps.to_set, Router.pinned_apps.map { |app| app.token }.to_set
  end
end