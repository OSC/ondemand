require 'test_helper'

class OodAppLinkTest < ActiveSupport::TestCase

  def setup
    @default_link_data = {
      title: "title",
      subtitle: "subtitle",
      description: "description",
      url: "url",
      icon_uri: "fas://test",
      caption: "caption",
      new_tab: false,
      data: { method: "post" },
    }
  end

  test "OodAppLink should update all properties based on hash input" do
    result = OodAppLink.new(@default_link_data)
    check_default_link_data(result)
  end

  test "OodAppLink expected defaults" do
    link_data = {}

    result = OodAppLink.new(link_data)
    assert_equal "",  result.title
    assert_equal "",  result.subtitle
    assert_equal "",  result.description
    assert_equal "",  result.url
    assert_equal URI("fas://cog"),  result.icon_uri
    assert_nil result.caption
    assert_equal true,  result.new_tab?
    assert_equal({},  result.data)
  end

  test "OodAppLink.to_h should create a hash with all link attributes" do
    result = OodAppLink.new(@default_link_data).to_h
    assert_equal "title",  result[:title]
    assert_equal "subtitle",  result[:subtitle]
    assert_equal "description",  result[:description]
    assert_equal "url",  result[:url]
    assert_equal URI("fas://test"),  result[:icon_uri]
    assert_equal "caption",  result[:caption]
    assert_equal false,  result[:new_tab]
    assert_equal({ method: "post" },  result[:data])
  end

  test "OodAppLink.categorize should create an OodAppLink with category, subcategory, and show_in_menu?" do
    result = OodAppLink.new(@default_link_data).categorize(category: "test_category", subcategory: "test_subcategory", show_in_menu: true)
    check_default_link_data(result)
    assert_equal "test_category",  result.category
    assert_equal "test_subcategory",  result.subcategory
    assert_equal true,  result.show_in_menu?
  end

  test "OodAppLink.categorize check defaults" do
    result = OodAppLink.new(@default_link_data).categorize
    check_default_link_data(result)
    assert_equal "",  result.category
    assert_equal "",  result.subcategory
    assert_equal false,  result.show_in_menu?
  end

  def check_default_link_data(link)
    assert_equal "title",  link.title
    assert_equal "subtitle",  link.subtitle
    assert_equal "description",  link.description
    assert_equal "url",  link.url
    assert_equal URI("fas://test"),  link.icon_uri
    assert_equal "caption",  link.caption
    assert_equal false,  link.new_tab?
    assert_equal({ method: "post" },  link.data)
  end

end