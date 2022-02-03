require 'test_helper'

class RouterTest < ActiveSupport::TestCase
  
  def setup
    Router.instance_variable_set('@pinned_apps', nil)
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    stub_usr_router
    setup_usr_fixtures
  end

  def teardown
    teardown_usr_fixtures
    Router.instance_variable_set('@pinned_apps', nil)
  end

  def all_apps
    DevRouter.apps + SysRouter.apps + UsrRouter.all_apps(owners: UsrRouter.owners)
  end

  def sys_with_gateway_tokens
    [
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
    assert_equal real_tokens.to_set, pinned_apps.map(&:token).to_set
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
    assert_equal real_tokens.to_set, pinned_apps.map(&:token).to_set
  end

  test "pinned apps with wildcarded sys apps" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))

    pinned_apps = Router.pinned_apps(['sys/*'], all_apps)
    assert_equal sys_with_gateway_tokens.to_set, pinned_apps.map(&:token).to_set
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
    assert_equal tokens.to_set, pinned_apps.map(&:token).to_set
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
    assert_equal real_tokens.to_set, pinned_apps.map(&:token).to_set
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
    assert_equal tokens.to_set, pinned_apps.map(&:token).to_set
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
    assert_equal tokens.to_set, pinned_apps.map(&:token).to_set
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
      "dev/broken_app",
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
    assert_equal tokens.to_set, pinned_apps.map(&:token).to_set
  end

  test "pinned apps wont duplicate entries" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    cfg = ['sys/bc_jupyter', 'sys/*', 'sys/bc_jupyter', 'sys/pseudofun']

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal sys_with_gateway_tokens.to_set, pinned_apps.map(&:token).to_set
  end

  test "specifying type is same as glob" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    cfg = [{ type: 'sys' }]

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal sys_with_gateway_tokens.to_set, pinned_apps.map(&:token).to_set
  end

  test "specifying category" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    cfg = [{ category: 'Interactive Apps' }]

    interactive_apps = [
      "dev/bc_jupyter",
      "dev/bc_paraview",
      "dev/bc_desktop/oakley",
      "dev/bc_desktop/owens",

      "sys/bc_jupyter",
      "sys/bc_paraview",
      "sys/bc_desktop/oakley",
      "sys/bc_desktop/owens",

      "usr/shared/bc_app",
      "usr/shared/bc_with_subapps/oakley",
      "usr/shared/bc_with_subapps/owens"
    ]

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal interactive_apps.to_set, pinned_apps.map(&:token).to_set
  end

  test "specifying category and type" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    cfg = [{ type: 'sys', category: 'Interactive Apps' }]

    interactive_sys_apps = [
      "sys/bc_jupyter",
      "sys/bc_paraview",
      "sys/bc_desktop/oakley",
      "sys/bc_desktop/owens",
    ]

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal interactive_sys_apps.to_set, pinned_apps.map(&:token).to_set
  end

  test "specifying category, subcategory and type" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    cfg = [{ type: 'sys', category: 'Interactive Apps', subcategory: 'Desktops' }]

    desktops = [
      "sys/bc_desktop/oakley",
      "sys/bc_desktop/owens",
    ]

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal desktops.to_set, pinned_apps.map(&:token).to_set
  end

  test "specifying non existant categories and subcategories" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    cfg = [{ type: 'sys', category: 'Fiction', subcategory: 'Science Fiction' }]

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal [].to_set, pinned_apps.map(&:token).to_set
  end

  test "specifying the wrong type" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    cfg = [{ type: 'other' }]

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal [].to_set, pinned_apps.map(&:token).to_set
  end

  test "mixed hash and string configurations" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    cfg = [
      "dev/*",
      { type: 'sys', category: 'Interactive Apps', subcategory: 'Desktops' }
    ]

    tokens = [
      "dev/activejobs",
      "dev/bc_desktop/oakley",  # dev/* gives the 2 subapps, not the main app
      "dev/bc_desktop/owens",
      "dev/bc_jupyter",
      "dev/bc_paraview",
      "dev/dashboard",
      "dev/file-editor",
      "dev/files",
      "dev/myjobs",
      "dev/shell",
      "dev/systemstatus",
      "dev/pseudofun",

      "sys/bc_desktop/oakley",
      "sys/bc_desktop/owens",
    ]

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal tokens.to_set, pinned_apps.map(&:token).to_set
  end

  test "metadata works with other fields" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    cfg = [
      {
        type: 'sys',
        category: 'Interactive Apps',
        machine_learning: 'true'
      }
    ]

    tokens = [
      "sys/bc_jupyter"
    ]

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal tokens.to_set, pinned_apps.map(&:token).to_set
  end

  test "multiple metadata matches work" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    cfg = [
      { machine_learning: 'true' },
      { field_of_science: 'biology' }
    ]

    tokens = [
      "sys/bc_jupyter",
      "sys/pseudofun",

      "dev/bc_jupyter",
      "dev/pseudofun"
    ]

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal tokens.to_set, pinned_apps.map(&:token).to_set
  end

  test "metadata * globs work" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    cfg = [
      { languages: '*python*' }
    ]

    tokens = [
      "sys/bc_jupyter", # both apps have python
      "sys/pseudofun",

      "dev/bc_jupyter",
      "dev/pseudofun"
    ]

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal tokens.to_set, pinned_apps.map(&:token).to_set
  end

  test "multiple metadata globs pull multiple apps" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    cfg = [
      { languages: '{*ruby*,*ErlanG*}' } # note case in erlang. manifests have erLANG and Ruby
    ]

    tokens = [
      "sys/bc_jupyter", # jupyter has ruby but not erlang
      "sys/pseudofun", # pseduofun has erlang but not ruby

      "dev/bc_jupyter",
      "dev/pseudofun"
    ]

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal tokens.to_set, pinned_apps.map(&:token).to_set
  end

  test "multiple metadata globs filter apps" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    cfg = [
      { languages: '*ruby*' }
    ]

    # only jupyter matches ruby
    tokens = [
      "sys/bc_jupyter",
      "dev/bc_jupyter"
    ]

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal tokens.to_set, pinned_apps.map(&:token).to_set
  end

  test "bad metadata returns emtpy" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    cfg = [
      { machine_learning: 'false' },
      { field_of_science: 'magic' }
    ]

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal [].to_set, pinned_apps.map(&:token).to_set
  end

  test "empty hashes and string return nothing" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    cfg = [
      "",
      {}
    ]

    pinned_apps = Router.pinned_apps(cfg, all_apps)
    assert_equal [].to_set, pinned_apps.map(&:token).to_set
  end

  test "nils return nothing" do
    SysRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))

    pinned_apps = Router.pinned_apps(nil, nil)
    assert_equal [].to_set, pinned_apps.map(&:token).to_set
  end
end
