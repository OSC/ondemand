# frozen_string_literal: true

require 'test_helper'

class CustomPagesIntegrationTest < ActionDispatch::IntegrationTest
  test 'should render configured page layout' do
    stub_user_configuration({
                              custom_pages: {
                                docs: {
                                  rows: [
                                    { columns: [
                                      {
                                        widgets: 'custom_pages_test'
                                      }
                                    ] },
                                    { columns: [
                                      {
                                        width:   8,
                                        widgets: 'custom_pages_test'
                                      }
                                    ] }
                                  ]
                                }
                              }
                            })

    get custom_pages_path(page_code: 'docs')

    assert :success
    assert_select 'div.row', 2
    assert_select 'div.row > div.col-md-12', 1
    assert_select 'div.row > div.col-md-12 > h3', text: 'Custom Pages Test Widget'
    assert_select 'div.row > div.col-md-8', 1
    assert_select 'div.row > div.col-md-8 > h3', text: 'Custom Pages Test Widget'
  end

  test 'should render error message when page is not found' do
    stub_user_configuration({ custom_pages: {} })

    get custom_pages_path(page_code: 'not_defined')

    assert :success
    # There should be 3 alert-danger divs
    # js placeholder
    # browser warning
    # custom page not found
    assert_select "div.alert-danger[role='alert']", 3
    assert_select "div.alert-danger[role='alert']" do |elements|
      assert_match(/Invalid page code: not_defined/, elements[2].text)
    end
  end
end
