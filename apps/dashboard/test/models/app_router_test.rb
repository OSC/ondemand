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

  test "DevRouter.apps should only apps that have periods in directory name" do
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
end
