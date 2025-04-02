# frozen_string_literal: true

require 'application_system_test_case'

class ProductsDevTest < ApplicationSystemTestCase
  # Since :dev gives more selections page interactions are tested here.

  def setup
    DevRouter.stubs(:base_path).returns(Pathname.new('test/fixtures/sys_with_gateway_apps'))
    Configuration.stubs(:app_development_enabled?).returns(true)
    visit products_path(:dev)
  end

  test 'Home Breadcrumb button works' do
    find('ol', class: 'breadcrumb').find('li', text: 'Home')
    click_on 'Home'
  end

  test 'New App route is correct' do
    button_link?('New App', '/pun/sys/dashboard/admin/dev/products/new')
  end

  test 'Launch Shell route is correct' do
    find('span', class: 'float-end').find('.btn', text: 'Launch Shell')
    has_link?('/pun/sys/shell/ssh')
  end

  test 'Launch Files route is correct' do
    button_link?('Launch Files', '/pun/sys/dashboard/files/fs')
  end

  test 'Can click dev Launch Jupyter' do
    click_on 'Launch Jupyter'
    assert_equal current_path, new_batch_connect_session_context_path('dev/bc_jupyter')
  end

  test 'Can click Launch Oakley Desktop' do
    click_on 'Launch Oakley Desktop'
    assert_equal current_path, new_batch_connect_session_context_path('dev/bc_desktop/oakley')
  end

  test 'Can click Launch Owens Desktop' do
    click_on 'Launch Owens Desktop'
    assert_equal current_path, new_batch_connect_session_context_path('dev/bc_desktop/owens')
  end

  test 'Can click dev Launch Paraview' do
    click_on 'Launch Paraview'
    assert_equal current_path, new_batch_connect_session_context_path('dev/bc_paraview')
  end

  test 'Can click dev Launch Active Jobs' do
    button_link?('Launch Active Jobs', '/pun/sys/dashboard/apps/show/activejobs/dev/')
  end

  test 'Can click dev Launch Home Directory' do
    button_link?('Launch Active Jobs', '/pun/sys/dashboard/apps/show/activejobs/dev/')
  end

  test 'Can click dev Launch file-editor' do
    button_link?('Launch osc-editor', '/pun/sys/dashboard/apps/show/file-editor/dev/')
  end

  test 'Can click dev Launch My Jobs' do
    button_link?('Launch My Jobs', '/pun/sys/dashboard/apps/show/myjobs/dev/')
  end

  test 'HTML renders all rows for apps in Product Table' do
    find(id: 'productTable')
    assert_selector 'tr', count: 13
  end

  test 'pressing bundle install' do
    visit(product_url('dev', 'dashboard'))
    assert find('#product_cli_modal', visible: :hidden)

    # tests cannot handle the transition when the modal closes.
    update_script = <<~JAVASCRIPT
      document.getElementById("product_cli_modal").classList.remove('fade');
    JAVASCRIPT

    execute_script(update_script)

    # now the modal pops up and you can click to dismiss it
    click_on 'Bundle Install'
    assert find('#product_cli_modal', visible: :visible)
    click_button('product_cli_modal_button')
    assert find('#product_cli_modal', visible: :hidden)
  end

  test 'pressing app restart' do
    visit(product_url('dev', 'dashboard'))
    assert find('#product_cli_modal', visible: :hidden)

    # tests cannot handle the transition when the modal closes.
    update_script = <<~JAVASCRIPT
      document.getElementById("product_cli_modal").classList.remove('fade');
    JAVASCRIPT

    execute_script(update_script)

    # now the modal pops up and you can click to dismiss it
    click_on 'Restart App'
    assert find('#product_cli_modal', visible: :visible)
    click_button('product_cli_modal_button')
    assert find('#product_cli_modal', visible: :hidden)
  end

  test 'picking a new icon' do
    Dir.mktmpdir do |dir|
      FileUtils.cp_r('test/fixtures/sys_with_gateway_apps/dashboard', dir)
      DevRouter.stubs(:base_path).returns(Pathname.new(dir))

      visit edit_product_path('dev', 'dashboard')
      assert_equal 'fas fa-cog fa-fw app-icon', find_css_class('product_icon')

      find('#icon_dumpster_fire').click

      assert_equal 'fas fa-dumpster-fire fa-fw app-icon', find_css_class('product_icon')
      click_on 'Save'
      sleep 1
      actual_manifest = File.read("#{dir}/dashboard/manifest.yml")
      expected_manifest = <<~HEREDOC
        ---
        name: Ood Dashboard
        description: stuff
        icon: fas://dumpster-fire
      HEREDOC

      assert_equal(product_path('dev', 'dashboard'), current_path)
      assert_equal(expected_manifest, actual_manifest)
    end
  end
end
