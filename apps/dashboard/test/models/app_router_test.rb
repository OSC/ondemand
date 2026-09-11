require 'test_helper'

class AppRouterTest < ActiveSupport::TestCase
  test "DevRouter.apps" do
    dir = Pathname.new(File.realpath(Dir.mktmpdir))
    DevRouter.stubs(:base_path).returns(dir)
    %w(a b c .git).each {|d| dir.join(d).mkdir }
    FileUtils.touch dir.join("d.txt").to_s
    dir.join("c").chmod(0600)
    dir.join("d.txt").chmod(0700)

    assert_equal ["a", "b"].sort, DevRouter.apps.map(&:name).sort

    dir.rmtree()
  end

  test "SysRouter.apps should hide apps that have periods in directory name" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)
      [
        "app1",
        ".app2",
        "app-3",
        "app.4"
      ].each { |d| dir.join(d).mkdir }

      SysRouter.stubs(:base_path).returns(dir)

      apps = SysRouter.apps.map(&:name).sort
      assert_equal ["app1", "app-3"].sort, apps
    end
  end

  test "UsrRouter.apps should hide apps that have periods in directory name" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)
      [
        "app1",
        ".app2",
        "app-3",
        "app.4"
      ].each { |d| dir.join(d).mkdir }

      UsrRouter.stubs(:base_path).returns(dir)

      apps = UsrRouter.apps.map(&:name).sort
      assert_equal ["app1", "app-3"].sort, apps
    end
  end

  test "UsrRouter.caption when user is a group (or non-existance user)" do
    assert_equal "Shared by PZS0714", UsrRouter.new('foo', 'PZS0714').caption
  end

  test "DevRouter.apps should hide apps that have periods in directory name" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)
      [
        "app1",
        ".app2",
        "app-3",
        "app.4"
      ].each { |d| dir.join(d).mkdir }

      DevRouter.stubs(:base_path).returns(dir)

      apps = DevRouter.apps.map(&:name).sort
      assert_equal ["app1", "app-3"].sort, apps
    end
  end

  test "SysRouter.apps should hide configured apps that have periods in directory name" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)
      [
        "app1",
        ".app2",
        "app-3",
        "app.4"
      ].each { |d| dir.join(d).mkdir }

      Configuration.stubs(:external_apps_config).returns([{path: dir, owner: CurrentUser.name, prefix: 'new'}])

      apps = SysRouter.apps.map(&:name).sort
      assert_equal ["app1", "app-3"].sort, apps
    end
  end

  test 'SysRouter.apps includes configured apps' do
    Dir.mktmpdir 'apps' do |dir|
      dir = Pathname.new(dir)
      sys_dir = dir.join('sys')
      ext_dir = dir.join('ext')

      ['sys_app1', 'sys_app2', 'sys_app3'].each {|d| sys_dir.join(d).mkpath }
      ['ext_app1', 'ext_app2', 'ext_app3'].each {|d| ext_dir.join(d).mkpath }

      SysRouter.stubs(:base_path).returns(sys_dir)
      Configuration.stubs(:external_apps_config).returns([{path: ext_dir.to_s, owner: CurrentUser.name, prefix: 'new'}])

      all_apps = ['ext_app1', 'ext_app2', 'ext_app3', 'sys_app1', 'sys_app2', 'sys_app3'].sort
      assert_equal all_apps, SysRouter.apps.map(&:name).sort
    end
  end

  test "SysRouter.apps should hide apps from untrusted users" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)
      good_app = dir.join('trusted_app')
      bad_app  = dir.join('other_app')
      [good_app, bad_app].each(&:mkdir)

      Configuration.stubs(:external_apps_config).returns([{path: dir.to_s, owner: CurrentUser.name, prefix: 'ext'}])

      original_stat = File.method(:stat)
      File.stubs(:stat).with(bad_app.to_s).returns(OpenStruct.new({uid: 0, world_writable?: true}))
      File.stubs(:stat).with(dir.parent.to_s).returns(original_stat.call(dir.parent.to_s))
      File.stubs(:stat).with(dir.to_s       ).returns(original_stat.call(dir.to_s))
      File.stubs(:stat).with(good_app.to_s  ).returns(original_stat.call(dir.to_s))
      
      assert_equal [good_app.basename.to_s], SysRouter.apps.map(&:name)
    end
  end
end
