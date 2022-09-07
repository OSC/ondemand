require 'test_helper'

class AppRecategorizerTest < ActiveSupport::TestCase

  test "should create an OodApp with category and subcategory" do
    result = AppRecategorizer.new(stub(), category: "test_category", subcategory: "test_subcategory")
    assert_equal "test_category",  result.category
    assert_equal "test_subcategory",  result.subcategory
  end

end