require 'test_helper'

class NavTest < ActionDispatch::IntegrationTest
 test "default for app to open in new window" do
   SysRouter.stubs(:base_path).returns(Rails.root.parent)
   Configuration.stubs(:open_apps_in_new_window?).returns(true)

   get '/'

   link = css_select('a[title="Job Composer"]').first

   assert link, "Job Composer link not found on index page"
   assert_equal '_blank', link['target'], 'Job Composer link should be set to open in new window'
 end

 test "default for app to open in same window" do
   SysRouter.stubs(:base_path).returns(Rails.root.parent)
   Configuration.stubs(:open_apps_in_new_window?).returns(false)

   get '/'

   link = css_select('a[title="Job Composer"]').first

   assert link, 'Job Composer link not found on index page'
   refute link['target'], 'Job Composer link should be set to open in same window'
 end

 test "user menu dropdown is rendered when new_user_menu property is true" do
   SysRouter.stubs(:base_path).returns(Rails.root.parent)
   stub_user_configuration({ new_user_menu: true })

   get '/'

   assert_select "#navbar li.dropdown[title=\"#{CurrentUser.name}\"] a[data-toggle]", text: CurrentUser.name
   assert_select "#navbar ul.navbar-nav > li.nav-item a.nav-link", text: I18n.t('dashboard.nav_user', username: CurrentUser.name), count: 0
   assert_select "#navbar ul.navbar-nav > li.nav-item a.nav-link", text: I18n.t('dashboard.nav_logout'), count: 0
 end

 test "logged in user and logout links are rendered when new_user_menu property is false" do
   SysRouter.stubs(:base_path).returns(Rails.root.parent)
   stub_user_configuration({ new_user_menu: false })

   get '/'

   assert_select "#navbar li.dropdown[title=\"#{CurrentUser.name}\"]", 0
   assert_select "#navbar ul.navbar-nav > li.nav-item a.nav-link", text: I18n.t('dashboard.nav_user', username: CurrentUser.name), count: 1
   assert_select "#navbar ul.navbar-nav > li.nav-item a.nav-link", text: I18n.t('dashboard.nav_logout'), count: 1
 end
end
