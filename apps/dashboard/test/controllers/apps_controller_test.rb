require 'test_helper'

class AppsControllerTest < ActionController::TestCase
  def setup
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_interactive_apps"))
    DevRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/dev"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))

    UsrRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/usr"))
    UsrRouter.stubs(:owners).returns([Etc.getlogin])
  end

  test "default table is correct" do
    OodAppkit.stubs(:clusters).returns([]) # this gets rid of interactive apps
    get :index

    headers = css_select('tr[id="all-apps-table-header"] th')
    assert_equal I18n.t('dashboard.all_apps_table_app_column'), headers[0].text
    assert_equal I18n.t('dashboard.all_apps_table_install_column'), headers[1].text
    assert_equal I18n.t('dashboard.all_apps_table_category_column'), headers[2].text
    assert_equal I18n.t('dashboard.all_apps_table_sub_category_column'), headers[3].text

    data_rows = css_select('table[id="all-apps-table"] tr').slice(1, 100)

    # ensure the table has only system installed apps
    assert_equal 5, data_rows.size
    system_install = I18n.t('dashboard.all_apps_table_install_location_sys')
    data_rows.each do |row|
      assert_equal system_install, row.xpath('./td[2]').text
    end

    row_ids = [
      "pun-sys-shell-ssh-default",
      "apps-show-systemstatus",
      "pun-sys-files",
      "apps-show-activejobs",
      "apps-show-myjobs",
    ]

    row_ids.each do |id|
      assert_select "tr[id='#{id}']", 1
    end
  end

  test "table shows interactive sys apps with dev and usr apps" do
    Configuration.stubs(:app_development_enabled?).returns(true)
    Configuration.stubs(:app_sharing_enabled?).returns(true)
    puts "all usr apps: #{UsrRouter.all_apps(owners: UsrRouter.owners)[0].links[0].url}"
    get :index

    data_rows = css_select('table[id="all-apps-table"] tr').slice(1, 100)

    assert_equal 11, data_rows.size

    # difference here is shell apps have hosts in them (and there are 2 of them)
    # all interactive apps are shown along with the dev and usr apps
    row_ids = [
      "pun-sys-shell-ssh-oakley.osc.edu",
      "pun-sys-shell-ssh-owens.osc.edu",
      "apps-show-systemstatus",
      "pun-sys-files",
      "batch_connect-sys-bc_desktop-oakley-session_contexts-new",
      "batch_connect-sys-bc_jupyter-session_contexts-new",
      "batch_connect-sys-bc_paraview-session_contexts-new",
      "apps-show-activejobs",
      "apps-show-myjobs",
      "batch_connect-dev-bc_rstudio-session_contexts-new",  # the dev app
      "apps-show-results_manager_v2-usr-#{Etc.getlogin}"    # the usr app
    ]

    row_ids.each do |id|
      assert_select "tr[id='#{id}']", 1
    end
  end
end
