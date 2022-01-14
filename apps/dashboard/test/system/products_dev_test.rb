require 'application_system_test_case'

class ProductsDevTest < ApplicationSystemTestCase
  # Since :dev gives more selections page interactions are tested here.

  def setup
    DevRouter.stubs(:base_path).returns(Pathname.new("test/fixtures/sys_with_gateway_apps"))
    Configuration.stubs(:app_development_enabled?).returns(true)
    visit products_path(:dev)
  end

  test 'Home Breadcrumb button works' do
    find('ol', class: 'breadcrumb').find('li', text: 'Home')
    click_on 'Home'
  end

  test 'New App route is correct' do
    find('.btn', text: 'New App')
    has_link?('/pun/sys/dashboard/admin/dev/products/new')
  end

  test 'Launch Shell route is correct' do
    find('span', class: 'float-right').find('.btn', text: 'Launch Shell')
    has_link?('/pun/sys/shell/ssh')
  end

  test 'Launch Files route is correct' do
    find('.btn', text: 'Launch Files')
    has_link?('/pun/sys/dashboard/files/fs')
  end

  test 'Can click dev Launch Jupyter' do
    click_on 'Launch Jupyter'
  end

  test 'Can click Launch Oakley Desktop' do
    click_on 'Launch Oakley Desktop'
  end

  test 'Can click Launch Owens Desktop' do
    click_on 'Launch Owens Desktop'
  end

  test 'Can click dev Launch Paraview' do
    click_on 'Launch Paraview'
  end

  test 'Can click dev Launch Active Jobs' do
    find('.btn', text: 'Launch Active Jobs')
    has_link?('/pun/sys/dashboard/apps/show/activejobs/dev/')
  end

  test 'Can click dev Launch Home Directory' do
    find('.btn', text: 'Launch Active Jobs')
    has_link?('/pun/sys/dashboard/apps/show/activejobs/dev/')
  end

  test 'Can click dev Launch file-editor' do
    find('.btn', text: 'Launch osc-editor')
    has_link?('/pun/sys/dashboard/apps/show/file-editor/dev/')
  end

  test 'Can click dev Launch My Jobs' do
    find('.btn', text: 'Launch My Jobs')
    has_link?('/pun/sys/dashboard/apps/show/myjobs/dev/')
  end

  test 'HTML renders 12 rows for 12 apps in Product Table' do
    find(id: 'productTable')
    assert_selector 'tr', count: 12
  end
end
