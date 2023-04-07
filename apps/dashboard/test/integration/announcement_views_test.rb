require 'test_helper'

class AnnouncementViewsTest < ActionDispatch::IntegrationTest
  test "announcement is displayed if exists" do
    f = Tempfile.open(["announcement", ".md"])
    f.write %{Test announcement.}
    f.close

    stub_user_configuration({announcement_path: [f.path]})

    begin
      get "/"
      assert_response :success
      assert_select "div.announcement", "Test announcement."
    ensure
      stub_user_configuration({})
    end
  end
end
