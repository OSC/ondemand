# frozen_string_literal: true

require 'test_helper'
require 'html_helper'

class DashboardControllerTest < ActionDispatch::IntegrationTest
  def setup
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys'))
    Router.instance_variable_set('@pinned_apps', nil)
  end

  def teardown
    Router.instance_variable_set('@pinned_apps', nil)
  end

  test 'should create Jobs dropdown' do
    get root_path

    dditems = dropdown_list_items(dropdown_list('Jobs'))
    assert dditems.any?, 'dropdown list items not found'
    assert_equal ['Active Jobs', 'My Jobs'], dditems
  end

  test 'should create Files dropdown' do
    scratch_path = File.expand_path 'test/fixtures/dummy_fs/scratch'
    project_path = File.expand_path 'test/fixtures/dummy_fs/project'
    project_path2 = Pathname.new('test/fixtures/dummy_fs/project2').expand_path
    missing_path = '/test/fixtures/dummy_fs/missing'

    OodFilesApp.stubs(:candidate_favorite_paths).returns(
      [
        FavoritePath.new(scratch_path, title: 'Scratch'),
        project_path,
        project_path2,
        missing_path,
        FavoritePath.new('/mybucket', title: 'S3', filesystem: 's3')
      ]
    )

    get root_path

    dditems = dropdown_list_items(dropdown_list('Files'))
    assert dditems.any?, 'dropdown list items not found'
    assert_equal [
      'Home Directory',
      "Scratch #{scratch_path}",
      project_path,
      project_path2.to_s,
      'S3 /mybucket'
    ], dditems.map { |e| e.gsub(/\s+/, ' ') }, 'Files dropdown item text is incorrect'

    dditemurls = dropdown_list_items_urls(dropdown_list('Files'))
    assert_equal [
      "/pun/sys/files/fs#{Dir.home}",
      "/pun/sys/files/fs#{scratch_path}",
      "/pun/sys/files/fs#{project_path}",
      "/pun/sys/files/fs#{project_path2}",
      '/pun/sys/files/s3/mybucket'
    ], dditemurls, 'Files dropdown URLs are incorrect'
  end

  test 'should create Clusters dropdown with valid clusters that are alphabetically ordered by title' do
    OodAppkit.stubs(:clusters).returns(
      OodCore::Clusters.new([
        { id: :cluster1, metadata: { title: 'Cluster B' }, login: { host: 'host' } },
        { id: :cluster2, metadata: { title: 'Cluster D' }, login: { host: 'host' } },
        { id: :cluster3, metadata: { title: 'Cluster C' }, login: { host: 'host' } },
        { id: :cluster4, metadata: { title: 'Cluster A' }, login: { host: 'host' } },
        { id: :cluster5, metadata: { title: 'Cluster NoLogin' }, login: nil },
        { id: :cluster6, metadata: { title: 'Cluster NoAccess' }, login: { host: 'host' },
acls: [{ adapter: :group, groups: ['GROUP'] }] }
      ].map { |h| OodCore::Cluster.new(h) })
    )

    get root_path

    dd = dropdown_list('Clusters')
    dditems = dropdown_list_items(dd)

    assert dditems.any?, 'dropdown list items not found'

    assert_equal [
      'Cluster A Shell Access',
      'Cluster B Shell Access',
      'Cluster C Shell Access',
      'Cluster D Shell Access',
      'System Status'
    ], dditems

    assert_select dd, 'li a', 'System Status' do |link|
      assert_equal '/apps/show/systemstatus', link.first['href'], 'System Status link is incorrect'
    end
  end

  test 'should create Interactive Apps dropdown' do
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys_with_interactive_apps'))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))

    get root_path

    dd = dropdown_list('Interactive Apps')
    dditems = dropdown_list_items(dd)
    assert dditems.any?, 'dropdown list items not found'
    assert_equal [
      { header: 'Apps' },
      'Jupyter Notebook',
      'Paraview',
      :divider,
      { header: 'Desktops' },
      'Oakley Desktop',
      :divider,
      'Broken App'
    ], dditems

    assert_select dd, 'li a', 'Oakley Desktop' do |link|
      assert_equal '/batch_connect/sys/bc_desktop/oakley/session_contexts/new', link.first['href'],
                   'Desktops link is incorrect'
    end
  end

  test 'should create My Interactive Apps link if Interactive Apps exist and not developer' do
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys_with_interactive_apps'))
    Configuration.stubs(:app_development_enabled?).returns(false)
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))

    get root_path
    assert_response :success
    assert_select "nav a[href='#{batch_connect_sessions_path}']", 1
  end

  test 'should create My Interactive Apps link if no Interactive Apps and developer' do
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys'))
    Configuration.stubs(:app_development_enabled?).returns(true)
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))

    get root_path
    assert_response :success
    assert_select "nav a[href='#{batch_connect_sessions_path}']", 1
  end

  test 'should not create My Interactive Apps link if no Interactive Apps and not developer' do
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys'))
    Configuration.stubs(:app_development_enabled?).returns(false)
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))

    get root_path
    assert_response :success
    assert_select "nav a[href='#{batch_connect_sessions_path}']", 0
  end

  test 'UserConfiguration.categories should filter and order the navigation' do
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys_with_gateway_apps'))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))

    stub_user_configuration({
                              nav_categories: ['Files', 'Interactive Apps', 'Clusters']
                            })

    get root_path
    assert_response :success
    assert_select dropdown_links, 4 # +1 here is 'Help'
    assert_select  dropdown_link(1), text: 'Files'
    assert_select  dropdown_link(2), text: 'Interactive Apps'
    assert_select  dropdown_link(3), text: 'Clusters'
  end

  test 'should not create app menus if UserConfiguration.categories is empty' do
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys_with_gateway_apps'))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))

    stub_user_configuration({
                              nav_categories: []
                            })

    get root_path
    assert_response :success
    assert_select dropdown_links, 1 # +1 here is 'Help'
    assert_select dropdown_link(1), text: 'Help' # ensure is Help
  end

  test 'apps with no category should not appear in menu' do
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys_with_gateway_apps'))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))

    get root_path

    assert_select ".navbar-expand-md > #navbar li.dropdown[title='System Installed Apps']", 0,
                  'Apps with no category should not appear in menus (thus System Installed Apps)'
  end

  test 'should not create any empty links' do
    get root_path

    assert_response :success
    assert_select "a[href='']", count: 0
  end
end
