require 'test_helper'

class RouterTest < ActiveSupport::TestCase

  UserDouble = Struct.new(:name)
  
  def setup
    Router.instance_variable_set('@pinned_apps', nil)
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

  def all_apps
    DevRouter.apps + SysRouter.apps + UsrRouter.all_apps(owners: UsrRouter.owners)
  end

  test "pinned apps returns at least empty" do
    UsrRouter.stubs(:base_path).returns(Pathname.new("/dev/null"))
    assert_equal [], Router.pinned_apps([], [])
  end

  test "pinned apps with specific dev apps" do
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    real_tokens = [
      'dev/bc_jupyter',
      'dev/bc_paraview',
      'dev/bc_desktop/owens',
      'dev/pseudofun',
    ]

    tokens = real_tokens + [
      'sys/bc_desktop/doesnt_exist',
      'sys/should_get_filtered'
    ]
    
    pinned_apps = Router.pinned_apps(tokens, all_apps)
    assert_equal real_tokens.to_set, pinned_apps.map { |app| app.token }.to_set
  end

  test "pinned apps with specific sys apps" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    real_tokens = [
      'sys/bc_jupyter',
      'sys/bc_paraview',
      'sys/bc_desktop/owens',
      'sys/pseudofun'
    ]

    tokens = real_tokens + [
      'sys/bc_desktop/doesnt_exist',
      'sys/should_get_filtered'
    ]

    pinned_apps = Router.pinned_apps(tokens, all_apps)    
    assert_equal real_tokens.to_set, pinned_apps.map { |app| app.token }.to_set
  end

  test "pinned apps with wildcarded sys apps" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))

    tokens = [
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
    pinned_apps = Router.pinned_apps(['sys/*'], all_apps)    
    assert_equal tokens.to_set, pinned_apps.map { |app| app.token }.to_set
  end

  test "pinned apps with wildcarded sys sub apps" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    tokens = [
      "sys/bc_desktop/oakley",
      "sys/bc_desktop/owens",
      "sys/bc_jupyter",
      "sys/pseudofun"
    ]

    cfg = [
      "sys/bc_desktop/*",
      "sys/bc_jupyter",
      "sys/pseudofun"
    ]

    pinned_apps = Router.pinned_apps(cfg, all_apps)    
    assert_equal tokens.to_set, pinned_apps.map { |app| app.token }.to_set
  end

  test "pinned apps with specific usr apps" do
    UsrRouter.stubs(:base_path).with(:owner => "me").returns(Pathname.new("test/fixtures/usr/me"))
    UsrRouter.stubs(:base_path).with(:owner => 'shared').returns(Pathname.new("test/fixtures/usr/shared"))
    UsrRouter.stubs(:base_path).with(:owner => 'cant_see').returns(Pathname.new("test/fixtures/usr/cant_see"))
    UsrRouter.stubs(:owners).returns(['me', 'shared', 'cant_see'])

    real_tokens = [
      'usr/shared/bc_with_subapps/owens',
      'usr/me/my_shared_app',
    ]

    tokens = real_tokens + [
      'usr/doesnt_exist/some_app',
      'usr/should_get_filtered',
      'usr/cant_see/app_one',
      'usr/cant_see/app_two',
    ]

    pinned_apps = Router.pinned_apps(tokens, all_apps)
    assert_equal real_tokens.to_set, pinned_apps.map { |app| app.token }.to_set
  end

  test "pinned apps with wildcarded usr apps" do
    tokens = [
      'usr/shared/bc_with_subapps/oakley',
      'usr/shared/bc_with_subapps/owens',
      'usr/shared/bc_app',
      'usr/me/my_shared_app'
    ]

    cfg = [
      'usr/shared/*',
      'usr/me/*',
      'usr/cant_see/*',
      'usr/doesnt_exist/some_app',
      'usr/should_get_filtered'
    ]

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal tokens.to_set, pinned_apps.map { |app| app.token }.to_set
  end

  test "pinned apps with wildcarded usr sub apps apps" do
    tokens = [
      'usr/shared/bc_with_subapps/oakley',
      'usr/shared/bc_with_subapps/owens',
      'usr/me/my_shared_app'
    ]

    cfg = [
      'usr/shared/bc_with_subapps/*', # subapps/* here. usr/shared/bc_app not included
      'usr/me/*',
      'usr/cant_see/*',
      'usr/doesnt_exist/some_app',
      'usr/should_get_filtered'
    ]

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal tokens.to_set, pinned_apps.map { |app| app.token }.to_set
  end

  test "pinned apps with usr sys and dev apps" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_interactive_apps"))

    tokens = [  
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

    cfg = [
      'usr/shared/bc_with_subapps/*',
      'usr/me/*',
      'usr/shared/cant_see',
      'sys/bc_paraview',
      'sys/bc_desktop/*',
      'sys/bc_jupyter',
      'sys/pseudofun',
      'dev/*'
    ]

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal tokens.to_set, pinned_apps.map { |app| app.token }.to_set
  end

  test "pinned apps wont duplicate entries" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    cfg = ['sys/bc_jupyter', 'sys/*', 'sys/bc_jupyter', 'sys/pseudofun']

    tokens = [
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

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal tokens.to_set, pinned_apps.map { |app| app.token }.to_set
  end
end