require "smart_attributes"

class SmartAttributes::AttributeTest < ActiveSupport::TestCase

  test"widget should default to text_field" do
    target = SmartAttributes::Attribute.new("test", {})

    assert_equal "text_field", target.widget
  end

  test"widget should be configurable with options" do
    target = SmartAttributes::Attribute.new("test", { widget: "widget_value" })

    assert_equal "widget_value", target.widget
  end

  test"label should default to title version of id" do
    target = SmartAttributes::Attribute.new("some_attribute", {})

    assert_equal "Some Attribute", target.label
  end

  test"label should be configurable with options" do
    target = SmartAttributes::Attribute.new("test", { label: "Label Value" })

    assert_equal "Label Value", target.label
  end

  test"hide_when_empty? should default to false" do
    target = SmartAttributes::Attribute.new("test", {})

    assert_equal false, target.hide_when_empty?
  end

  test"hide_when_empty? should be configurable with options" do
    target = SmartAttributes::Attribute.new("test", { hide_when_empty: true })

    assert_equal true, target.hide_when_empty?
  end

  test"value should return a string" do
    assert_equal "string_value", SmartAttributes::Attribute.new("test", { value: "string_value" }).value
    assert_equal "true", SmartAttributes::Attribute.new("test", { value: true }).value
    assert_equal "1234", SmartAttributes::Attribute.new("test", { value: 1234 }).value
    assert_equal "[]", SmartAttributes::Attribute.new("test", { value:  [] }).value
  end

  test"value should not convert to string when widget is file_attachments" do
    assert_equal [], SmartAttributes::Attribute.new("test", { widget: "file_attachments", value: [] }).value
  end

  test"value should not convert to string when widget is file_field" do
    assert_equal [], SmartAttributes::Attribute.new("test", { widget: "file_field", value: [] }).value
  end

  test"value should not convert to string when value is UploadedFile class" do
    upload_file = Rack::Test::UploadedFile.new(StringIO.new("test file upload"), original_filename: "test_file")
    assert_equal upload_file, SmartAttributes::Attribute.new("test", { value: upload_file }).value
  end


end