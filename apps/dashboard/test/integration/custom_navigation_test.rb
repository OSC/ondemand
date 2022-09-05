require 'test_helper'

class CustomNavigationTest < ActionDispatch::IntegrationTest
 test "should render a custom navigation menu when nav_bar is defined in UserConfiguration" do
   # Mock the sys installed applications
   SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys"))
   # Test a navigation item of each type
   stub_user_configuration({nav_bar: [
     {title: "Custom Menu",
      links: [
        {title: "Custom Menu Dropdown Header"},
        {title: "Menu Link",
         url: "/menu/link"}
      ]},
     {title: "Custom Apps",
      links: [
        {title: "Custom Apps Dropdown Header"},
        {title: "App Link",
         app: "sys/systemstatus"}
      ]},
     {title: "Custom Tokens",
      links: [
        {title: "Custom Tokens Dropdown Header"},
        {tokens: ["sys/systemstatus"]}
      ]},
     {title: "Custom Link",
      url: "/custom/link"},
     {template: "all_apps"},
   ]})

   get root_path
   assert_response :success
   # Check nav menus
   assert_select "#navbar li.dropdown[title]", 4 # +1 here is 'Help'
   # Check nav links
   assert_select "#navbar li a.nav-link[title]", 1

   assert_select nav_menu(1), text: "Custom Menu"
   assert_select nav_menu_header("Custom Menu"), text: "Custom Menu Dropdown Header"
   assert_select nav_menu_link("Custom Menu", 1), text: "Menu Link"
   assert_select nav_menu_link("Custom Menu", 1) do |link|
     assert_equal "/menu/link", link.first['href']
   end

   assert_select nav_menu(2), text: "Custom Apps"
   assert_select nav_menu_header("Custom Apps"), text: "Custom Apps Dropdown Header"
   assert_select nav_menu_link("Custom Apps", 1), text: "App Link"
   assert_select nav_menu_link("Custom Apps", 1) do |link|
     assert_equal "/apps/show/systemstatus", link.first['href']
   end

   assert_select nav_menu(3), text: "Custom Tokens"
   assert_select nav_menu_header("Custom Tokens"), text: "Custom Tokens Dropdown Header"
   assert_select nav_menu_link("Custom Tokens", 1), text: "System Status"
   assert_select nav_menu_link("Custom Tokens", 1) do |link|
     assert_equal "/apps/show/systemstatus", link.first['href']
   end

   assert_select nav_link("Custom Link"), text: "Custom Link"
   assert_select nav_link("Custom Link") do |link|
     assert_equal "/custom/link", link.first['href']
   end

   # Check all_apps template.
   assert_select "#navbar .navbar-nav li.nav-item[title='All Apps']", text: "All Apps"
 end

 def nav_menu(order)
   "#navbar .navbar-nav li.dropdown:nth-of-type(#{order}) a"
 end

 def nav_menu_link(title, order)
   "#navbar .navbar-nav li.dropdown[title='#{title}'] ul.dropdown-menu a:nth-of-type(#{order})"
 end

 def nav_menu_header(title)
   "#navbar .navbar-nav li.dropdown[title='#{title}'] ul.dropdown-menu li.dropdown-header"
 end

 def nav_link(title)
   "#navbar .navbar-nav li a.nav-link[title='#{title}']"
 end
end
