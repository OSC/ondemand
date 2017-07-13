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
      assert_match /app does not supply.*a form file/, app.validation_reason
    }
  end

  test "test default app title" do
    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir + "/missing_app")
      assert_equal "Missing App", BatchConnect::App.new(router: r).title
      assert_equal "Owens Vdi", BatchConnect::App.new(router: r, sub_app: "owens-vdi").title
    }
  end
end
