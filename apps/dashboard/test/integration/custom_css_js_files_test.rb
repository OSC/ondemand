# frozen_string_literal: true

require 'test_helper'

class CustomCssJsFilesTest < ActionDispatch::IntegrationTest
  test 'should add css tags when custom_css_files configuration is set' do
    stub_user_configuration({ custom_css_files: ['test.css', '/custom/other.css'] })

    get '/'

    assert_select("link[href='/public/test.css'][nonce]")
    assert_select("link[href='/public/custom/other.css'][nonce]")
  end

  test 'should add javascript tags when custom_javascript_files configuration is set' do
    stub_user_configuration({ custom_javascript_files: ['test.js', '/custom/other.js'] })

    get '/'

    assert_select("script[src='/public/test.js'][nonce]")
    assert_select("script[src='/public/custom/other.js'][nonce]")
  end

  test 'should add javascript tags with type when custom_javascript_files configuration is set' do
    stub_user_configuration({ custom_javascript_files: [{ src: 'test.js', type: 'module' }] })

    get '/'

    assert_select("script[src='/public/test.js'][type='module'][nonce]")
  end
end
