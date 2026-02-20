# frozen_string_literal: true

require 'application_system_test_case'

class ToggleBehaviorTest < ApplicationSystemTestCase
  TOGGLE_WAIT = 0.5

  def setup
    stub_sys_apps
    stub_user
    stub_clusters
    stub_sinfo
  end

  def setup_project(root_dir, override_project_dir = nil)
    OodAppkit.stubs(:dataroot).returns(Pathname.new(root_dir))

    proj = 'test-project'
    desc = 'test-description'
    icon = 'fas://arrow-right'
    visit projects_path
    click_on I18n.t('dashboard.jobs_create_blank_project')
    find('#project_name').set(proj)
    find('#project_directory').set(override_project_dir) if override_project_dir
    find('#project_description').set(desc)
    find('#product_icon_select').set(icon)
    click_on 'Save'

    project_element = find('.project-card')
    project_id = project_element[:id]

    project_dir = override_project_dir || "#{root_dir}/projects/#{project_id}"
    `echo 'some_other_command' > #{project_dir}/my_cool_script.sh`
    `echo 'hostname' > #{project_dir}/my_cooler_script.bash`

    project_id
  end

  # FIXME: Duplicated from project_test_helper.rb
  def setup_launcher(project_id)
    visit project_path(project_id)
    click_on 'New Launcher'
    find('#launcher_title').set('the launcher title')
    click_on 'Save'

    launcher_element = all('#launcher_list div.list-group-item').first
    launcher_element[:id].gsub('launcher_', '')
  end

  # FIXME: Duplicated from project_test_helper.rb
  def setup_workflow(dir)
    workflow_dir = Pathname.new(dir).join('workflows')
    workflow_dir.mkdir

    Configuration.stubs(:workflows_dir).returns(workflow_dir)
    workflow_dir
  end

  test 'navbar toggler expands and collapses nav on mobile' do    
    visit root_path

    # Resize to mobile view
    original_size = page.current_window.size
    page.current_window.resize_to(500, 800)

    navbar_toggler = find('.navbar-toggler')
    navbar_collapse = find('#navbar', visible: :all)

    assert_not navbar_collapse.visible?, 'Navbar should be initially collapsed on mobile'

    navbar_toggler.click
    assert_selector('#navbar.show')
    assert navbar_collapse.visible?, 'Navbar should be visible after toggle click'

    navbar_toggler.click
    # #navbar.collapse.show -> navbar.collapsing -> navbar.collapse
    # So we have to wait until show is removed before checking when collapse appears
    refute_selector('#navbar.show')
    refute_selector('#navbar.collapsing')
    
    assert_not navbar_collapse.visible?, 'Navbar should be hidden after second toggle click'
    
    # Reset window to original size
    page.current_window.resize_to(original_size[0], original_size[1])
  end

  test 'navbar dropdown items toggle visibility' do
    visit root_path
    navbar_dropdowns = all('nav .nav-item.dropdown')

    navbar_dropdowns.each_with_index do |dropdown, index|
      toggle = dropdown.find('.dropdown-toggle')
      menu = dropdown.find('.dropdown-menu', visible: :all)

      assert_not menu.visible?, "Navbar dropdown #{index + 1} menu should be hidden initially"

      toggle.click
      assert_selector('.dropdown-menu.show')
      assert menu.visible?, "Navbar dropdown #{index + 1} menu should be visible after click"

      toggle.click
      refute_selector('.dropdown-menu.show')
      assert_not menu.visible?, "Navbar dropdown #{index + 1} menu should be hidden after second click"
    end
  end

  test 'project launcher list toggle works' do
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      visit project_path(project_id)
      launcher_id = setup_launcher(project_id)

      toggle_button = find('a[data-bs-target="#launcher_list"]')
      launcher_list = find('#launcher_list', visible: :all)

      assert launcher_list.visible?, 'Launcher list should be visible initially'

      toggle_button.click
      refute_selector('#launcher_list.show')
      refute_selector('#launcher_list.collapsing')
      assert_not launcher_list.visible?, 'Launcher list should be hidden after toggle'

      toggle_button.click
      assert_selector('#launcher_list.show')
      assert launcher_list.visible?, 'Launcher list should be visible after second toggle'
    end
  end

  test 'workflow list toggle works' do
    Configuration.stubs(:workflows_enabled).returns(true)
    
    Dir.mktmpdir do |dir|
      project_id = setup_project(dir)
      
      visit project_path(project_id)

      toggle_button = find('a[data-bs-target="#workflow_list"]')
      workflow_list = find('#workflow_list', visible: :all)

      assert workflow_list.visible?, 'Workflow list should be visible initially'

      toggle_button.click
      refute_selector('#workflow_list.show')
      assert_not workflow_list.visible?, 'Workflow list should be hidden after toggle'

      toggle_button.click
      assert_selector('#workflow_list.show')
      assert workflow_list.visible?, 'Workflow list should be visible after second toggle'
    end
  end

  test 'module browser toggles module details' do
    Configuration.stubs(:module_file_dir).returns('test/fixtures/modules')

    visit module_browser_path

    module_button = find('.module-card button[data-bs-toggle="collapse"]', match: :first)
    target_id = module_button[:'data-bs-target']
    collapsible_element = find(target_id, visible: :all)

    assert_not collapsible_element.visible?, 'Module details should be collapsed initially'
    assert_equal 'false', module_button[:'aria-expanded']

    module_button.click
    assert_selector('.module-card button[data-bs-toggle="collapse"].active')
    assert collapsible_element.visible?, 'Module details should be visible after click'
    assert_equal 'true', module_button[:'aria-expanded']

    module_button.click
    refute_selector('.module-card button[data-bs-toggle="collapse"].active')
    assert_not collapsible_element.visible?, 'Module details should be hidden after second click'
    assert_equal 'false', module_button[:'aria-expanded']
  end
end
