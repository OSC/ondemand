require 'test_helper'

class AppsTest < ActionDispatch::IntegrationTest

  test "index table adds metadata columns" do
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file("test/fixtures/config/clusters.d"))
    Configuration.stubs(:app_development_enabled?).returns(true)
    Configuration.stubs(:app_sharing_enabled?).returns(true)
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
  
    get "/apps/index"
    assert_response :success
  
    headers = css_select('tr[id="all-apps-table-header"] th')
  
    assert_equal 6, headers.size
    assert_equal 'Field Of Science', headers[4].text
    assert_equal 'Machine Learning', headers[5].text

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
      meta0 = css_select("tr[id='#{row_id}']").xpath('./td[5]').text
      meta1 = css_select("tr[id='#{row_id}']").xpath('./td[6]').text
      
      assert_equal data[0], meta0
      assert_equal data[1], meta1
    end
  end
end
