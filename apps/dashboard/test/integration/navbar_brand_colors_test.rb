# frozen_string_literal: true

require 'test_helper'

class NavbarBrandColorsTest < ActionDispatch::IntegrationTest
  test 'navbar styles include default background colors when brand text colors are unset' do
    stub_user_configuration({})

    get '/'

    assert_response :success
    assert_select 'style', text: /--bs-navbar-color/, count: 0
    assert_select 'style', text: /--bs-navbar-hover-color/, count: 0
    assert_select 'style', text: /--bs-navbar-active-color/, count: 0
  end

  test 'navbar styles include configured brand link text colors' do
    stub_user_configuration({
                              brand_link_color:        '#112233',
                              brand_link_hover_color:  '#445566',
                              brand_link_active_color: '#778899'
                            })

    get '/'

    assert_response :success
    assert_select 'style', text: /--bs-navbar-color:\s*#112233/
    assert_select 'style', text: /--bs-navbar-brand-color:\s*#112233/
    assert_select 'style', text: /--bs-navbar-disabled-color:\s*#112233/
    assert_select 'style', text: /--bs-navbar-hover-color:\s*#445566/
    assert_select 'style', text: /--bs-navbar-brand-hover-color:\s*#445566/
    assert_select 'style', text: /--bs-navbar-active-color:\s*#778899/
  end

  test 'navbar styles include only the brand text colors that are configured' do
    stub_user_configuration({ brand_link_hover_color: '#abcdef' })

    get '/'

    assert_response :success
    assert_select 'style', text: /--bs-navbar-hover-color:\s*#abcdef/
    assert_select 'style', text: /--bs-navbar-brand-hover-color:\s*#abcdef/
    assert_select 'style', text: /--bs-navbar-color/, count: 0
    assert_select 'style', text: /--bs-navbar-active-color/, count: 0
  end
end
