# frozen_string_literal: true

require 'test_helper'

class NavTest < ActionDispatch::IntegrationTest
  test 'default for app to open in new window' do
    SysRouter.stubs(:base_path).returns(Rails.root.parent)
    Configuration.stubs(:open_apps_in_new_window?).returns(true)

    get('/')

    link = css_select('a[title="Job Composer"]').first

    assert(link, 'Job Composer link not found on index page')
    assert_equal('_blank', link['target'], 'Job Composer link should be set to open in new window')
  end

  test 'default for app to open in same window' do
    SysRouter.stubs(:base_path).returns(Rails.root.parent)
    Configuration.stubs(:open_apps_in_new_window?).returns(false)

    get('/')

    link = css_select('a[title="Job Composer"]').first

    assert(link, 'Job Composer link not found on index page')
    refute(link['target'], 'Job Composer link should be set to open in same window')
  end

  test 'external app uses its URL directly in navbar' do
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys_with_gateway_apps'))
    Configuration.stubs(:open_apps_in_new_window?).returns(false)

    get('/')

    link = css_select('a[title="External Link App"]').first

    assert(link, 'External Link App not found on index page')
    assert_equal('https://external.example.com', link['href'])
  end

  test 'renders pinned_apps when nav_bar is empty and pinned_apps are configured' do
    stub_sys_apps
    stub_user_configuration({
                          pinned_apps: [
                            'sys/bc_jupyter',
                            'sys/bc_paraview',
                            'sys/bc_desktop/owens',
                            'sys/pseudofun',
                          ],
                        })

    get('/')

    assert_response(:success)
    assert_select("nav.navbar div.collapse li.nav-item") do
      #shows Apps dropdown buttono
      assert_select("a.nav-link.dropdown-toggle[title = '#{I18n.t("dashboard.pinned_apps_category")}']", 1)

      #dropdown menu list
      assert_select("ul.dropdown-menu[title = '#{I18n.t("dashboard.pinned_apps_category")}']", 1) do
        # Pinned Apps header
        assert_select("li.dropdown-header", text: "#{I18n.t("dashboard.pinned_apps_title")}")

        # Pinned apps
        assert_select("a.dropdown-item[title='Jupyter Notebook']", 1)
        assert_select("a.dropdown-item[title='Paraview']", 1)
        assert_select("a.dropdown-item[title='Owens Desktop']", 1)
        assert_select("a.dropdown-item[title='PseudoFuN']", 1)

        # All Apps link
        assert_select("li[title='#{I18n.t("dashboard.nav_all_apps")}']") do
          assert_select("a.dropdown-item[href='#{apps_index_path}']", 1)
        end
      end
    end
  end

  test 'does not render pinned_apps when nav_bar is empty and pinned_apps are empty' do
    stub_sys_apps
    stub_user_configuration({pinned_apps: []})

    get('/')

    assert_response(:success)
    assert_select("nav.navbar div.collapse li.nav-item a.nav-link.dropdown-toggle[title = '#{I18n.t("dashboard.pinned_apps_category")}']", 0)
  end

  test 'Files, Jobs, Clusters, and Interactive Apps nav_bar groups should render' do
    stub_sys_apps
    Configuration.stubs(:open_apps_in_new_window?).returns(false)

    get('/')

    assert_response(:success)

    #test if File menu and items exist
    assert_select("nav.navbar div.collapse li.nav-item a.nav-link.dropdown-toggle[title='Files']", 1)
    assert_select("nav.navbar div.collapse li.nav-item ul.dropdown-menu[title='Files']", 1) do
      assert_select("li a[title='#{I18n.t('dashboard.home_directory')}']", 1)
    end

    #test if Job menu and items exist
    assert_select("nav.navbar div.collapse li.nav-item a.nav-link.dropdown-toggle[title='Jobs']", 1)
    assert_select("nav.navbar div.collapse li.nav-item ul.dropdown-menu[title='Jobs']", 1) do
      assert_select("li a[title='Active Jobs']", 1)
    end

    assert_select("nav.navbar div.collapse li.nav-item a.nav-link.dropdown-toggle[title='Clusters']", 1)
    assert_select("nav.navbar div.collapse li.nav-item ul.dropdown-menu[title='Clusters']", 1) do
      assert_select("li a[title='Owens Shell Access']", 1)
      assert_select("li a[title='System Status']", 1)
    end

    assert_select("nav.navbar div.collapse li.nav-item a.nav-link.dropdown-toggle[title='Interactive Apps']", 1)
    assert_select("nav.navbar div.collapse li.nav-item ul.dropdown-menu[title='Interactive Apps']", 1) do
      assert_select("li a[title='Jupyter Notebook']", 1)
      assert_select("li a[title='Paraview']", 1)
      assert_select("li a[title='Owens Desktop']", 1)
      assert_select("li a[title='Paraview']", 1)
    end
  end

  test 'navbar sessions should render' do
    stub_sys_apps
    Configuration.stubs(:open_apps_in_new_window?).returns(true)
    get('/')
    assert_response(:success)
    assert_select("nav.navbar div.collapse li.nav-item a.nav-link[title='#{I18n.t('dashboard.nav_sessions')}']", 1)
  end

  test 'navbar sessions should not render' do
    stub_sys_apps
    Configuration.stubs(:open_apps_in_new_window?).returns(false)
    ApplicationController.any_instance.stubs(:sys_app_groups).returns([])

    get('/')
    assert_response(:success)
    assert_select("nav.navbar div.collapse li.nav-item a.nav-link[title='#{I18n.t('dashboard.nav_sessions')}']", 0)
  end

  test 'all_apps should render' do
    stub_sys_apps
    stub_user_configuration(show_all_apps_link: true)
    get('/')
    assert_response(:success)
    assert_select("nav.navbar div.collapse li.nav-item a.nav-link[title='#{I18n.t('dashboard.nav_all_apps')}']", 1)
  end

  test 'all_apps should not render' do
    stub_sys_apps
    stub_user_configuration(show_all_apps_link: false)
    get('/')
    assert_response(:success)
    assert_select("nav.navbar div.collapse li.nav-item a.nav-link[title='#{I18n.t('dashboard.nav_all_apps')}']", 0)
  end
end
