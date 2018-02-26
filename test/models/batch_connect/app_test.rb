require 'test_helper'

class BatchConnect::AppTest < ActiveSupport::TestCase
  test "app with malformed form.yml" do
    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir)
      r.path.join("form.yml").write("--x-\nnot a valid form yaml")

      app = BatchConnect::App.new(router: r)
      assert ! app.valid?
    }
  end

  test "missing app handled gracefully" do
    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir + "/missing_app")
      app = BatchConnect::App.new(router: r)

      assert ! app.valid?
      assert_match /app does not exist/, app.validation_reason
    }
  end

  test "default app title" do
    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir + "/missing_app")
      assert_equal "Missing App", BatchConnect::App.new(router: r).title
      assert_equal "Missing App: Owens Vdi", BatchConnect::App.new(router: r, sub_app: "owens-vdi").title
    }
  end

  test "sub_apps_list doesn't crash when local directory inaccessible" do
    begin
      # place in begin/ensure so we can delete the directory after setting
      # back the permissions to 0700 on the local sub directory
      # the normal Dir.mktmpdir {} would result in an exception being thrown
      # when deleting the directories at the end of the test run
      #
      appdir = Pathname.new(Dir.mktmpdir)

      # create local dir but make it inaccessible
      localdir = appdir.join("local")
      localdir.mkdir
      localdir.chmod(0000)

      app = BatchConnect::App.new(router: PathRouter.new(appdir))

      assert 1, app.sub_app_list.count
      assert_equal app, app.sub_app_list.first
    ensure
      localdir.chmod(0700)
      appdir.rmtree
    end
  end
end
