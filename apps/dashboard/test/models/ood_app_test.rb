require 'test_helper'

class OodAppTest < ActiveSupport::TestCase
  test "passenger rack app detection" do
    Dir.mktmpdir { |dir|
      FileUtils.cp Rails.root.join("config.ru").to_s, dir
      assert OodApp.new(PathRouter.new(dir)).passenger_rack_app?
    }
  end

  test "passenger rails app detection" do
    Dir.mktmpdir { |dir|
      FileUtils.cp [Rails.root.join("config.ru").to_s, Rails.root.join("Gemfile").to_s, Rails.root.join("Gemfile.lock").to_s], dir
      assert OodApp.new(PathRouter.new(dir)).passenger_rails_app?
    }
  end

  # FIXME:
  # a rails app without a Gemfile.lock has no lock file that can be parsed
  # so we cannot determine which gems this app has
  # therefore it is a Rack app
  test "passenger rails app detection without Gemfile.lock" do
    Dir.mktmpdir { |dir|
      # here, instead of inspecting the Gemfile.lock, we need to inspect the Gemfile
      FileUtils.cp [Rails.root.join("config.ru").to_s, Rails.root.join("Gemfile").to_s], dir

      assert OodApp.new(PathRouter.new(dir)).passenger_rack_app?, "an app with a config.ru should be recognized as a rack app"

      #FIXME: to address the fixme above, change this assertion to true
      assert ! OodApp.new(PathRouter.new(dir)).passenger_rails_app?, "an app with a Gemfile but not a Gemfile.lock should not be recognized as a rails app"
    }
  end

  test "app is hidden if directory name begins with a period" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)

      app_dir = dir.join(".app").tap { |p| p.mkdir }
      assert OodApp.new(PathRouter.new(app_dir)).hidden?
    end
  end

  test "app is not hidden if directory name doesn't begin with a period" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)

      app_dir = dir.join("app").tap { |p| p.mkdir }
      refute OodApp.new(PathRouter.new(app_dir)).hidden?
    end
  end

  test "app is a backup if directory name has period in it" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)

      app_dir = dir.join("app.bak").tap { |p| p.mkdir }
      assert OodApp.new(PathRouter.new(app_dir)).backup?
    end
  end

  test "app is not a backup if directory name begins with a period" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)

      app_dir = dir.join(".app").tap { |p| p.mkdir }
      refute OodApp.new(PathRouter.new(app_dir)).backup?
    end
  end

  test "app is not a backup if directory name doesn't contain a period" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)

      app_dir = dir.join("app").tap { |p| p.mkdir }
      refute OodApp.new(PathRouter.new(app_dir)).backup?
    end
  end

  test "sys app with empty category should be hidden from nav" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)
      SysRouter.stubs(:base_path).returns(dir)

      app_dir = dir.join("app").tap { |p| p.mkdir }
      app_dir.join("manifest.yml").write("---\nname: Ood Dashboard\ndescription: stuff")

      refute OodApp.new(SysRouter.new(app_dir.basename.to_s)).should_appear_in_nav?
    end
  end

  test "sys app with category should appear in nav" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)
      SysRouter.stubs(:base_path).returns(dir)

      app_dir = dir.join("app").tap { |p| p.mkdir }
      app_dir.join("manifest.yml").write("---\nname: Jobs\ncategory: Jobs")

      assert OodApp.new(SysRouter.new(app_dir.basename.to_s)).should_appear_in_nav?
    end
  end
end
