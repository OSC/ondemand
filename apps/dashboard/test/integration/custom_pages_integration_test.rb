require 'test_helper'

class CustomPagesIntegrationTest < ActionDispatch::IntegrationTest

  test "should render configured page layout" do
    stub_user_configuration({
      custom_pages: {
        docs: {
          rows: [
            {columns: [
              {
                widgets: 'custom_pages_test'
              }
            ]},
            {columns: [
              {
                width: 8,
                widgets: 'custom_pages_test'
              }
            ]}
          ]
        }
      }
    })

    get custom_pages_path(page_code: "docs")

    assert :success
    assert_select 'div.row', 2
    assert_select 'div.row > div.col-md-12', 1
    assert_select 'div.row > div.col-md-12 > h3', text: "Custom Pages Test Widget"
    assert_select 'div.row > div.col-md-8', 1
    assert_select 'div.row > div.col-md-8 > h3', text: "Custom Pages Test Widget"
  end


end