# frozen_string_literal: true

require 'html_helper'
require 'test_helper'

# Test the feature for configuring landing pages through UserConfiguration#dashboard_layout.

# Note that the default layout (having no UserConfiguration#dashboard_layout set)
# and variants (MOTD enabled/disabled, XDMOD & MOTD enabled/disabled and so on) are handled
# by pinned_apps_test.rb.
class DashboardLayoutTest < ActionDispatch::IntegrationTest
  def setup
    Router.instance_variable_set('@pinned_apps', nil)
  end

  def teardown
    Router.instance_variable_set('@pinned_apps', nil)
  end

  def test_env
    {
      MOTD_FORMAT:    'osc',
      MOTD_PATH:      Rails.root.join('test/fixtures/files/motd_valid').to_s,
      # this is going to fail, but that's OK - the widets will still appear
      OOD_XDMOD_HOST: 'http://localhost'
    }
  end

  test 'should show nothing when nothing is given' do
    # XDMOD here isn't really
    stub_user_configuration({ dashboard_layout: {} })

    get '/'

    assert_select 'div.row', 0
  end

  test 'nil MOTD and pinned apps render empty elements' do
    stub_user_configuration({
                              dashboard_layout: {
                                rows: [
                                  {
                                    columns: [
                                      {
                                        width:   8,
                                        widgets: 'motd'
                                      },
                                      {
                                        width:   4,
                                        widgets: 'pinned_apps'
                                      }
                                    ]
                                  }
                                ]
                              }
                            })

    get '/'

    assert_select 'div.row', 1
    assert_select 'div.row > div.col-md-8', 1
    assert_select 'div.row > div.col-md-4', 1

    motd = css_select('div.row > div.col-md-8')
    pinned_apps = css_select('div.row > div.col-md-4')

    # they exist, but they're empty. No errors because you've configured to show them,
    # but not configured to create them
    assert_equal motd.children.size, 1
    assert_equal motd.children.first.to_s.gsub(/[\s\n]/, ''), ''
    assert_equal pinned_apps.children.size, 1
    assert_equal pinned_apps.children.first.to_s.gsub(/[\s\n]/, ''), ''
  end

  test 'shows MOTD a single row, single column' do
    stub_user_configuration({
                              dashboard_layout: {
                                rows: [
                                  {
                                    columns: [
                                      {
                                        width:   12,
                                        widgets: 'motd'
                                      }
                                    ]
                                  }
                                ]
                              }
                            })

    with_modified_env(test_env) do
      get '/'
    end

    assert_response :success

    assert_select 'div.row', 1
    assert_select 'div.row > div.col-md-12', 1
    assert_select 'div.row > div.col-md-12 > div.motd', 3
    assert_select 'div.row > div.col-md-12 > div.motd > h3', 3
    assert_select 'div.row > div.col-md-12 > div.motd > div.motd_body', 3
  end

  test 'shows widgets with one row and two columns' do
    stub_user_configuration({
                              dashboard_layout: {
                                rows: [
                                  {
                                    columns: [
                                      {
                                        width:   8,
                                        widgets: 'motd'
                                      },
                                      {
                                        width:   4,
                                        widgets: ['xdmod_widget_job_efficiency', 'xdmod_widget_jobs']
                                      }
                                    ]
                                  }
                                ]
                              }
                            })

    with_modified_env(test_env) do
      get '/'
    end

    assert_select 'div.row', 1
    assert_select 'div.row > div.col-md-8', 1
    assert_select 'div.row > div.col-md-8 > div.motd', 3
    assert_select 'div.row > div.col-md-8 > div.motd > h3', 3
    assert_select 'div.row > div.col-md-8 > div.motd > div.motd_body', 3

    assert_select 'div.row > div.col-md-4', 1
    assert_select 'div.row > div.col-md-4 > div.xdmod', 2
    assert_select 'div.row > div.col-md-4 > div.xdmod > [id="jobsEfficiencyReportPanelDiv"]', 1
    assert_select 'div.row > div.col-md-4 > div.xdmod > [id="coreHoursEfficiencyReportPanelDiv"]', 1
    assert_select 'div.row > div.col-md-4 > div.xdmod > [id="jobsPanelDiv"]', 1
  end

  test 'app sharing layout' do
    # MOTD + pinned apps, but no XDMOD
    env = {
      MOTD_FORMAT: 'osc',
      MOTD_PATH:   Rails.root.join('test/fixtures/files/motd_valid').to_s
    }

    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys_with_gateway_apps'))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))
    BatchConnect::Session.stubs(:cache_root).returns(Pathname('/dev/null'))
    stub_user_configuration({
                              pinned_apps: [
                                'sys/bc_jupyter',
                                'sys/bc_paraview',
                                'sys/bc_desktop/owens',
                                'sys/pseudofun'
                              ]
                            })

    with_modified_env(env) do
      get '/'
    end

    # pinned_apps makes rows for every 'group', resulting in 2 rows
    # recently used apps is also 1 row
    assert_select 'div.row', 3
    assert_select 'div.row > div.col-md-4', 1
    assert_select 'div.row > div.col-md-8', 1

    assert_select 'div.row > div.col-md-4', 1
    assert_select 'div.row > div.col-md-4 > div.motd', 3
    assert_select 'div.row > div.col-md-4 > div.motd > h3', 3
    assert_select 'div.row > div.col-md-4 > div.motd > div.motd_body', 3

    assert_select pinned_app_row_css_query('8'), 4
    assert_select pinned_app_link_css_query('8', '/batch_connect/sys/bc_jupyter/session_contexts/new'), 1
    assert_select pinned_app_link_css_query('8', '/batch_connect/sys/bc_paraview/session_contexts/new'), 1
    assert_select pinned_app_link_css_query('8', '/apps/show/pseudofun'), 1
    assert_select pinned_app_link_css_query('8', '/batch_connect/sys/bc_desktop/owens/session_contexts/new'), 1
  end

  test 'shows widgets on a second row' do
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys_with_gateway_apps'))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))
    stub_user_configuration({
                              pinned_apps:      [
                                'sys/bc_jupyter',
                                'sys/bc_paraview',
                                'sys/bc_desktop/owens',
                                'sys/pseudofun'
                              ],
                              dashboard_layout: {
                                rows: [
                                  {
                                    columns: [
                                      {
                                        width:   8,
                                        widgets: 'motd'
                                      },
                                      {
                                        width:   4,
                                        widgets: ['xdmod_widget_job_efficiency', 'xdmod_widget_jobs']
                                      }
                                    ]
                                  },
                                  {
                                    columns: [
                                      {
                                        width:   12,
                                        widgets: 'pinned_apps'
                                      }
                                    ]
                                  }
                                ]
                              }
                            })

    with_modified_env(test_env) do
      get '/'
    end

    assert_response :success

    assert_select 'div.row', 3 # one extra row because pinned_apps makes rows for every 'group'
    assert_select 'div.row > div.col-md-8', 1
    assert_select 'div.row > div.col-md-8 > div.motd', 3
    assert_select 'div.row > div.col-md-8 > div.motd > h3', 3
    assert_select 'div.row > div.col-md-8 > div.motd > div.motd_body', 3

    assert_select 'div.row > div.col-md-4', 1
    assert_select 'div.row > div.col-md-4 > div.xdmod', 2
    assert_select 'div.row > div.col-md-4 > div.xdmod > [id="jobsEfficiencyReportPanelDiv"]', 1
    assert_select 'div.row > div.col-md-4 > div.xdmod > [id="coreHoursEfficiencyReportPanelDiv"]', 1
    assert_select 'div.row > div.col-md-4 > div.xdmod > [id="jobsPanelDiv"]', 1

    assert_select 'div.row > div.col-md-12', 1
    assert_select pinned_app_row_css_query('12'), 4
    assert_select pinned_app_link_css_query('12', '/batch_connect/sys/bc_jupyter/session_contexts/new'), 1
    assert_select pinned_app_link_css_query('12', '/batch_connect/sys/bc_paraview/session_contexts/new'), 1
    assert_select pinned_app_link_css_query('12', '/apps/show/pseudofun'), 1
    assert_select pinned_app_link_css_query('12', '/batch_connect/sys/bc_desktop/owens/session_contexts/new'), 1
  end

  test "bad widgets don't throw errors" do
    stub_user_configuration({
                              dashboard_layout: {
                                rows: [
                                  {
                                    columns: [
                                      {
                                        width:   4,
                                        widgets: 'this_widget_doesnt_exist'
                                      },
                                      {
                                        width:   4,
                                        widgets: 'syntax_error'
                                      },
                                      {
                                        width:   4,
                                        widgets: 'load_error'
                                      }
                                    ]
                                  }
                                ]
                              }
                            })

    with_modified_env(test_env) do
      get '/'
    end

    assert_select 'div.row', 1
    assert_select 'div.row > div.col-md-4', 3

    error_widgets = css_select('div.row > div.col-md-4 > div.alert.alert-danger.card > div.card-body')
    assert_equal 3, error_widgets.size
    assert_equal true, %r{Missing partial widgets/_this_widget_doesnt_exist}.match?(error_widgets[0].text)
    assert_equal true, /undefined method `woops!'/.match?(error_widgets[1].text)
    assert_equal true, /cannot load such file -- the_missing_gem/.match?(error_widgets[2].text)
  end

  test 'should render brand new widgets with shipped widgets' do
    stub_user_configuration({
                              dashboard_layout: {
                                rows: [
                                  {
                                    columns: [
                                      {
                                        width:   6,
                                        widgets: 'test_partial'
                                      },
                                      {
                                        width:   6,
                                        widgets: 'motd'
                                      }
                                    ]
                                  }
                                ]
                              }
                            })

    with_modified_env(test_env) do
      get '/'
    end

    assert_select 'div.row', 1
    assert_select 'div.row > div.col-md-6', 2

    assert_select 'div.row > div.col-md-6 > div.motd', 3
    assert_select 'div.row > div.col-md-6 > div.motd > h3', 3
    assert_select 'div.row > div.col-md-6 > div.motd > div.motd_body', 3

    assert_select 'div.row > div.col-md-6 > #my-test-partial', 1
    actual_value = css_select('div.row > div.col-md-6 > #my-test-partial').text.gsub(/\n/, '').strip
    assert_equal "My Test Partial's now in the dashboard!", actual_value
  end

  test 'when recently used apps is populated' do
    Dir.mktmpdir do |dir|
      BatchConnect::Session.stubs(:cache_root).returns(Pathname.new(dir))
      stub_sys_apps
      cfg = {
        'cluster'           => 'quick',
        'bc_num_hours'      => 1,
        'bc_account'        => 'abc',
        'bc_vnc_resolution' => '1228x691'
      }
      File.write("#{dir}/sys_bc_paraview.json", cfg.to_json)

      get '/'

      assert_select 'div.row > div.col-md-12 > div.recently-used-apps-header > div.row', 1
      ruas = css_select('div.row > div.col-md-12 > div.recently-used-apps-header > div.row > div.app-launcher-container')
      assert_equal(1, ruas.size)

      header_text = css_select('h4.apps-section-header-blue').text
      assert_equal(I18n.t('dashboard.recently_used_apps_title'), header_text)
    end
  end
end
