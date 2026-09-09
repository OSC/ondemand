# frozen_string_literal: true

require 'test_helper'

class NavTest < ActionDispatch::IntegrationTest
  test 'default for app to open in new window' do
    SysRouter.stubs(:base_path).returns(Rails.root.parent)
    Configuration.stubs(:open_apps_in_new_window?).returns(true)

    get '/'

    link = css_select('a[title="Job Composer"]').first

    assert link, 'Job Composer link not found on index page'
    assert_equal '_blank', link['target'], 'Job Composer link should be set to open in new window'
  end

  test 'default for app to open in same window' do
    SysRouter.stubs(:base_path).returns(Rails.root.parent)
    Configuration.stubs(:open_apps_in_new_window?).returns(false)

    get '/'

    link = css_select('a[title="Job Composer"]').first

    assert link, 'Job Composer link not found on index page'
    refute link['target'], 'Job Composer link should be set to open in same window'
  end

  test 'external app uses its URL directly in navbar' do
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys_with_gateway_apps'))
    Configuration.stubs(:open_apps_in_new_window?).returns(false)
    Rails.cache.delete('sys_apps')

    get '/'

    link = css_select('a[title="External Link App"]').first

    assert link, 'External Link App not found on index page'
    assert_equal 'https://external.example.com', link['href']
  end

  test 'default navbar with pinned_apps' do
    stub_sys_apps
    stub_user_configuration({
                          pinned_apps: [
                            'sys/bc_jupyter',
                            'sys/bc_paraview',
                            'sys/bc_desktop/owens',
                            'sys/bc_desktop/doesnt_exist',
                            'sys/pseudofun',
                            'sys/should_get_filtered'
                          ]
                        })

    get '/'

    assert_response :success
    assert_select "nav.navbar div.collapse li.nav-item a.nav-link.dropdown-toggle[title = '#{I18n.t("dashboard.pinned_apps_category")}']"
  end

  test 'default navbar without pinned_apps' do
    stub_sys_apps
    stub_user_configuration({pinned_apps: []})

    get '/'

    assert_response :success
    assert_select "nav.navbar div.collapse li.nav-item a.nav-link.dropdown-toggle[title = '#{I18n.t("dashboard.pinned_apps_category")}']", 0
  end

  test 'default groups in default navbar ' do
    stub_sys_apps
    Configuration.stubs(:open_apps_in_new_window?).returns(false)

    get '/'

    assert_response :success

    #test if the default nav bar items/groups are present
    assert_select "nav.navbar div.collapse li.nav-item a.nav-link.dropdown-toggle[title='Files']", 1
    assert_select "nav.navbar div.collapse li.nav-item a.nav-link.dropdown-toggle[title='Jobs']", 1
    assert_select "nav.navbar div.collapse li.nav-item a.nav-link.dropdown-toggle[title='Clusters']", 1
    assert_select "nav.navbar div.collapse li.nav-item a.nav-link.dropdown-toggle[title='Interactive Apps']", 1
  end

  test 'default navbar sessions should render' do
    stub_sys_apps
    Configuration.stubs(:open_apps_in_new_window?).returns(true)
    get '/'
    assert_response :success
    assert_select "nav.navbar div.collapse li.nav-item a.nav-link[title='#{I18n.t('dashboard.nav_sessions')}']", 1
  end

  test 'default navbar sessions should not render' do
    stub_sys_apps
    Configuration.stubs(:open_apps_in_new_window?).returns(false)
    ApplicationController.any_instance.stubs(:sys_app_groups).returns([])

    get '/'
    assert_response :success
    assert_select "nav.navbar div.collapse li.nav-item a.nav-link[title='#{I18n.t('dashboard.nav_sessions')}']", 0
  end

  test 'default navbar with all_apps should render' do
    stub_sys_apps
    stub_user_configuration(show_all_apps_link: true)
    get '/'
    assert_response :success
    assert_select "nav.navbar div.collapse li.nav-item a.nav-link[title='#{I18n.t('dashboard.nav_all_apps')}']", 1
  end

  test 'default navbar with all_apps should not render' do
    stub_sys_apps
    stub_user_configuration(show_all_apps_link: false)
    get '/'
    assert_response :success
    assert_select "nav.navbar div.collapse li.nav-item a.nav-link[title='#{I18n.t('dashboard.nav_all_apps')}']", 0
  end
end
