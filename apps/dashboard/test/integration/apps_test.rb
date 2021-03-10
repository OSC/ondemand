require 'test_helper'

class AppsTest < ActionDispatch::IntegrationTest

  UserDouble = Struct.new(:name)

  def setup
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_interactive_apps"))
    DevRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/dev"))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))

    Router.instance_variable_set('@pinned_apps', nil)
    OodSupport::Process.stubs(:user).returns(UserDouble.new('me'))
    OodSupport::User.stubs(:new).returns(UserDouble.new('me'))
    FileUtils.chmod 0000, 'test/fixtures/usr/cant_see/'
    UsrRouter.stubs(:base_path).with(:owner => "me").returns(Pathname.new("test/fixtures/usr/me"))
    UsrRouter.stubs(:base_path).with(:owner => 'shared').returns(Pathname.new("test/fixtures/usr/shared"))
    UsrRouter.stubs(:base_path).with(:owner => 'cant_see').returns(Pathname.new("test/fixtures/usr/cant_see"))
    UsrRouter.stubs(:owners).returns(['me', 'shared', 'cant_see'])
  end

  def teardown
    FileUtils.chmod 0755, 'test/fixtures/usr/cant_see/'
    Router.instance_variable_set('@pinned_apps', nil)
  end

  test "default table is correct" do
    OodAppkit.stubs(:clusters).returns([]) # this gets rid of interactive apps
    get "/apps/index"

    headers = css_select('tr[id="all-apps-table-header"] th')
    assert_equal I18n.t('dashboard.all_apps_table_app_column'), headers[0].text
    assert_equal I18n.t('dashboard.all_apps_table_category_column'), headers[1].text
    assert_equal I18n.t('dashboard.all_apps_table_sub_category_column'), headers[2].text

    data_rows = css_select('table[id="all-apps-table"] tr').slice(1, 100)

    # ensure the table has only system installed apps
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

    get "/apps/index"

    data_rows = css_select('table[id="all-apps-table"] tr').slice(1, 100)

    assert_equal 14, data_rows.size

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
      "apps-show-my_shared_app-usr-me",                     # the usr apps
      "batch_connect-usr-shared-bc_app-session_contexts-new",
      "batch_connect-usr-shared-bc_with_subapps-owens-session_contexts-new",
      "batch_connect-usr-shared-bc_with_subapps-oakley-session_contexts-new"
    ]

    row_ids.each do |id|
      assert_select "tr[id='#{id}']", 1
    end
  end

  test "index table adds metadata columns" do
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    Configuration.stubs(:app_development_enabled?).returns(true)
    Configuration.stubs(:app_sharing_enabled?).returns(true)
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
  
    get "/apps/index"
    assert_response :success
  
    headers = css_select('tr[id="all-apps-table-header"] th')
  
    assert_equal 5, headers.size
    assert_equal 'Field Of Science', headers[3].text
    assert_equal 'Machine Learning', headers[4].text

    rows_test_data = {
      "pun-sys-shell-ssh-owens.osc.edu": ["", ""],
      "pun-sys-shell-ssh-oakley.osc.edu": ["", ""],
      "apps-show-systemstatus": ["", ""],
      "pun-sys-files": ["", ""],
      "apps-show-activejobs": ["", ""],
      "apps-show-myjobs": [ "", "" ],
      "batch_connect-sys-bc_paraview-session_contexts-new": ["", ""],
      "batch_connect-sys-bc_jupyter-session_contexts-new": ["", "true"], # machine learning metadata
      "batch_connect-sys-bc_desktop-owens-session_contexts-new": ["", ""],
      "batch_connect-sys-bc_desktop-oakley-session_contexts-new": ["", ""],
      "apps-show-pseudofun": ["biology", ""] # field of science metadata
    }

    rows_test_data.each do |row_id, data|
      assert_select "tr[id='#{row_id}']", 1
      meta0 = css_select("tr[id='#{row_id}']").xpath('./td[4]').text
      meta1 = css_select("tr[id='#{row_id}']").xpath('./td[5]').text
      
      assert_equal data[0], meta0
      assert_equal data[1], meta1
    end
  end
end
