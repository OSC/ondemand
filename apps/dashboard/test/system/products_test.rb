require 'application_system_test_case'

# check breadcrumbs
# button clicks
# html looks right (two rows should return a count of 2 on rows.each)

class ProductsTest < ApplicationSystemTestCase

  def stub_dev
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    Configuration.stubs(:app_development_enabled?).returns(true)
  end

  test 'Index of my_shared_app can be accessed' do
    stub_usr_router
    setup_usr_fixtures
    visit products_path(:usr)
    teardown_usr_fixtures
  end

  test 'Show of my_shared_app url can be accessed' do
    stub_usr_router
    setup_usr_fixtures
    visit product_path(:usr, 'my_shared_app')
    teardown_usr_fixtures
  end

  test 'Home Breadcrumb button works' do
    stub_dev
    visit products_path(:dev)
    find('ol', class: 'breadcrumb').find('li', text: 'Home')
    click_on 'Home'
  end

  test 'New App route is correct' do
    stub_dev
    visit products_path(:dev)
    find('.btn', text: 'New App')
    has_link?('/pun/sys/dashboard/admin/dev/products/new')
  end

  test 'Launch Shell route is correct' do
    stub_dev
    visit products_path(:dev)
    find('span', class: 'float-right').find('.btn', text: 'Launch Shell')
    has_link?('/pun/sys/shell/ssh')
  end

  test 'Launch Files route is correct' do
    stub_dev
    visit products_path(:dev)
    find('.btn', text: 'Launch Files')
    has_link?('/pun/sys/dashboard/files/fs')
  end

  test 'Can click dev Launch Jupyter' do
    stub_dev
    visit products_path(:dev)
    click_on 'Launch Jupyter'
  end

  test 'Can click Launch Oakley Desktop' do
    stub_dev
    visit products_path(:dev)
    click_on 'Launch Oakley Desktop'
  end

  test 'Can click Launch Owens Desktop' do
    stub_dev
    visit products_path(:dev)
    click_on 'Launch Owens Desktop'
  end

  test 'Can click dev Launch Paraview' do
    stub_dev
    visit products_path(:dev)
    click_on 'Launch Paraview'
  end

  test 'Can click dev Launch Active Jobs' do
    stub_dev
    visit products_path(:dev)
    find('.btn', text: 'Launch Active Jobs')
    has_link?('/pun/sys/dashboard/apps/show/activejobs/dev/')
  end

  test 'Can click dev Launch Home Directory' do
    stub_dev
    visit products_path(:dev)
    find('.btn', text: 'Launch Active Jobs')
    has_link?('/pun/sys/dashboard/apps/show/activejobs/dev/')
  end

  test 'Can click dev Launch file-editor' do
    stub_dev
    visit products_path(:dev)
    find('.btn', text: 'Launch osc-editor')
    has_link?('/pun/sys/dashboard/apps/show/file-editor/dev/')
  end

  test 'Can click dev Launch My Jobs' do
    stub_dev
    visit products_path(:dev)
    find('.btn', text: 'Launch My Jobs')
    has_link?('/pun/sys/dashboard/apps/show/myjobs/dev/')
  end

  test 'HTML renders 12 rows for 12 apps in Product Table' do
    stub_dev
    visit products_path(:dev)
    find(id: 'productTable')
    assert_selector 'tr', count: 12
  end
end