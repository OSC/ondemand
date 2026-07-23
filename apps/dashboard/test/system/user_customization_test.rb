# frozen_string_literal: true

require 'application_system_test_case'

class UserCustomizationTest < ApplicationSystemTestCase
  def stub_user_settings_store(dir)
    Configuration.stubs(:user_settings_file).returns(Pathname.new("#{dir}/settings.yml"))
  end

  def open_customization_panel
    find('a[href="#settings_panel"]').click
    assert_selector('div.offcanvas.show')
  end

  test 'customizations panel opens and renders without errors' do
    Dir.mktmpdir do |dir|
      stub_user_settings_store(dir)
      visit('/')
      open_customization_panel

      assert_selector('.offcanvas-header', text: I18n.t('dashboard.customizations'))
      assert_selector('.offcanvas-body form#new_user_customization')

      # initial states for each setting

      # favorite_paths
      assert_selector('#current_favorites li', count: 1)

      find('#current_favorites #new_favorite_item', text: I18n.t('dashboard.add_favorite_path')).click
      assert_selector('#new_favorite_path.show')

      assert_equal('', find('#favorite_path_title').value)
      assert_equal('', find('#favorite_path_path').value)
      assert_selector('button[data-bs-target="#favorite_path_path_path_selector"]')
      assert_selector('a[role="button"]', text: I18n.t('dashboard.add_favorite'))
  
      assert_equal('[]', find('input#user_customization_custom_files_favorites[type="hidden"]', visible: false).value)
    
      # shared "Save settings" button
      assert_equal(I18n.t('dashboard.save_changes'), find('#new_user_customization input[type="submit"]').value)
    end
  end

  test 'adding and removing custom files favorites' do
    Dir.mktmpdir do |dir|
      stub_user_settings_store(dir)
      visit(files_url(Rails.root))
      open_customization_panel

      # Adding favorite with no title
      first_path = FileUtils.pwd
      click_on(I18n.t('dashboard.add_favorite_path'))
      assert_selector('#new_favorite_path.show')
      find('#favorite_path_path').set(first_path)
      find('#new_favorite_button').click
      assert_selector('#current_favorites li', count: 2)
      assert_selector('#favorite_path_path[value=""]', visible: false)
      assert_selector("li[data-favorite-path='#{first_path}']", text: first_path)
      exp_json_1 = "{\"title\":\"\",\"path\":\"#{first_path}\"}"
      assert_equal("[#{exp_json_1}]", find('#user_customization_custom_files_favorites', visible: false).value)
      refute_selector('#new_favorite_path.collapsing')

      # Adding favorite with title
      second_path = '/'
      click_on(I18n.t('dashboard.add_favorite_path'))
      assert_selector('#new_favorite_path.show')
      find('#favorite_path_title').set('root')
      find('#favorite_path_path').set(second_path)
      find('#new_favorite_button').click
      assert_selector('#current_favorites li', count: 3)
      assert_selector('#favorite_path_title:not([value])', visible: false)
      assert_selector('#favorite_path_path[value=""]', visible: false)
      root_item = find("li[data-favorite-path='#{second_path}']", text: "root (#{second_path})")
      exp_json_2 = '{"title":"root","path":"/"}'
      assert_equal("[#{exp_json_1},#{exp_json_2}]", find('#user_customization_custom_files_favorites', visible: false).value)
      
      # delete an unsaved favorite item
      root_item.find("[data-delete-favorite]").click
      refute_selector("li[data-favorite-path='#{second_path}']")
      assert_selector('#current_favorites li', count: 2)
      assert_equal("[#{exp_json_1}]", find('#user_customization_custom_files_favorites', visible: false).value)

      # save and observe changes
      click_on(I18n.t('dashboard.save_changes'))
      assert_selector('ul#favorites li', count: 2)
      assert_selector("ul#favorites a.nav-link[href='#{files_path(first_path)}']", text: first_path)

      open_customization_panel
      click_on(I18n.t('dashboard.add_favorite_path'))
      assert_selector('#new_favorite_path.show')
      click_on(I18n.t('dashboard.select_path'))
      assert_selector('#favorite_path_path_path_selector.show')
      assert_selector('div#favorites a', count: 2)
      find('div#favorites a', text: first_path).click
      assert_selector('li.breadcrumb-item', text: File.basename(first_path))

      # since we're here, lets replace this favorite with a titled one
      find('#favorite_path_path_path_selector_button').click
      find('#favorite_path_path_path_selector .btn-close').click

      sleep 10
      refute_selector('#favorite_path_path_path_selector')
      assert_equal(first_path, find('#favorite_path_path').value)
      find('#favorite_path_title').set('Dashboard')
      find('#new_favorite_button').click
      assert_selector('#current_favorites li', count: 3)
      assert_selector('#favorite_path_title:not([value])', visible: false)
      assert_selector('#favorite_path_path[value=""]', visible: false)
      assert_selector("li[data-favorite-path='#{first_path}']", text: "Dashboard (#{first_path})")
      exp_json_3 = "{\"title\":\"Dashboard\",\"path\":\"#{first_path}\"}"
      assert_equal("[#{exp_json_1},#{exp_json_3}]", find('#user_customization_custom_files_favorites', visible: false).value)

      find_all('#current_favorites li').first.find('[data-delete-favorite]').click
      assert_selector('#current_favorites li', count: 2)
      assert_equal("[#{exp_json_3}]", find('#user_customization_custom_files_favorites', visible: false).value)

      click_on(I18n.t('dashboard.save_changes'))
      assert_selector('ul#favorites li', count: 2)
      assert_selector("ul#favorites a.nav-link[href='#{files_path(first_path)}']", text: first_path)

      open_customization_panel
      click_on(I18n.t('dashboard.add_favorite_path'))
      assert_selector('#new_favorite_path.show')
      click_on(I18n.t('dashboard.select_path'))
      assert_selector('#favorite_path_path_path_selector.show')
      assert_selector('div#favorites a', count: 2)
      click_on(first_path)
      assert_selector('li.breadcrumb-item', text: File.basename(first_path))
    end
  end

  test 'adding a path that does not exist' do
  end
end
