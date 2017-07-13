require 'test_helper'

class BatchConnect::AppTest < ActiveSupport::TestCase
  test "app with malformed form.yml" do
    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir)
      r.path.join("form.yml").write("--x-\nnot a valid form yaml")

      app = BatchConnect::App.new(router: r)

      assert_equal "No title set", app.title
      assert ! app.valid?
    }
  end

  test "missing app handled gracefully" do
    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir + "/missing_app")
      app = BatchConnect::App.new(router: r)

      assert_equal "No title set", app.title
      assert ! app.valid?
      assert_match /app does not supply.*a form file/, app.validation_reason
    }
  end
end
