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

  test "custom_css_paths should prepend public_url to all custom css file paths" do
    @user_configuration = stub(:custom_css_files => ['/test.css'], :public_url => Pathname.new("/public"))
    assert_equal ['/public/test.css'], custom_css_paths

    @user_configuration = stub(:custom_css_files => ['test.css'], :public_url => Pathname.new("/public"))
    assert_equal ['/public/test.css'], custom_css_paths

    @user_configuration = stub(:custom_css_files => ['/custom/css/test.css'], :public_url => Pathname.new("/public"))
    assert_equal ['/public/custom/css/test.css'], custom_css_paths

    @user_configuration = stub(:custom_css_files => ['custom/css/test.css'], :public_url => Pathname.new("/public"))
    assert_equal ['/public/custom/css/test.css'], custom_css_paths
  end

  test "custom_css_paths should should handle nil and empty file paths" do
    @user_configuration = stub(:custom_css_files => ['/test.css', nil, "other.css"], :public_url => Pathname.new("/public"))
    assert_equal ['/public/test.css', '/public/other.css'], custom_css_paths

    @user_configuration = stub(:custom_css_files => [nil], :public_url => Pathname.new("/public"))
    assert_equal [], custom_css_paths

    @user_configuration = stub(:custom_css_files => ['/test.css', "", "other.css"], :public_url => Pathname.new("/public"))
    assert_equal ['/public/test.css', '/public/other.css'], custom_css_paths

    @user_configuration = stub(:custom_css_files => [""], :public_url => Pathname.new("/public"))
    assert_equal [], custom_css_paths
  end
end
