require 'test_helper'

class AnnouncementViewsTest < ActionDispatch::IntegrationTest
  test "announcement is displayed if exists" do
    f = Tempfile.open(["announcement", ".md"])
    f.write %{Test announcement.}
    f.close

    Configuration.stubs(:announcement_path).returns(f.path)

    begin
      get "/"
      assert_response :success
      assert_select "div.announcement", "Test announcement."
    ensure
      Configuration.unstub(:announcement_path)
    end
  end
end
