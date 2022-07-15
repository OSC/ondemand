require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  include ApplicationHelper

  def setup
    @user_configuration = nil
  end

  test "profile_links should delegate to user_configuration object" do
    expected_result = ["a", "b", "c"]
    @user_configuration = stub(:profile_links => expected_result)

    assert_equal expected_result, profile_links
  end

  test "profile_link should return nil when id is missing" do
    invalid_profile_link = {
      name: "test name",
      icon: "user"
    }

    assert_nil profile_link(invalid_profile_link)
  end

  test "profile_link should return a link with data-method set to post containing an icon and text" do
    profile_link = {
      id: "test",
      name: "test name",
      icon: "user"
    }
    result = profile_link(profile_link)

    html_doc = Nokogiri::HTML(result)

    refute_nil html_doc.at_css('a[data-method="post"]')
    refute_nil html_doc.at_css('a[data-method="post"] i')
    assert_equal true, html_doc.at_css('a[data-method="post"] i')["class"].include?(profile_link[:icon])
    assert_equal profile_link[:name], html_doc.at_css('a[data-method="post"]').text.strip
  end
end
