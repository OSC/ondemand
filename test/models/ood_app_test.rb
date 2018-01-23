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

  test "should set apps with period in directory as invalid" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)

      app_dir = dir.join("app").tap { |p| p.mkdir }
      assert OodApp.new(PathRouter.new(app_dir)).valid_dir?

      app_dir = dir.join(".app").tap { |p| p.mkdir }
      refute OodApp.new(PathRouter.new(app_dir)).valid_dir?

      app_dir = dir.join("app.bak").tap { |p| p.mkdir }
      refute OodApp.new(PathRouter.new(app_dir)).valid_dir?
    end
  end
end
