# frozen_string_literal: true

require 'application_system_test_case'

class UserCustomizationTest < ApplicationSystemTestCase
  def teardown
    Singleton.__init__(UserCustomization)
  end

  def stub_system_favorites(dir)
    path1 = File.join(dir, 'fav_dir_1')
    path2 = File.join(dir, 'other_dir')
    favorites = [path1, path2].map do |d|
      FileUtils.mkdir_p(d)
      FavoritePath.new(d)
    end
    OodFilesApp.any_instance.stubs(:candidate_favorite_paths).returns(favorites)
  end

  def wait_for_favorites_reload
    execute_script("document.documentElement.setAttribute('data-before-favorites-reload', '')")
    yield
    # Match the new document without querying visibility on nodes that are unloading.
    assert_selector('html:not([data-before-favorites-reload]) #favorites', visible: :all)
  end

  test 'adding files favorites' do
    Dir.mktmpdir do |dir|
      stub_system_favorites(dir)
      settings_file = File.join(dir, '.user_settings.txt')
      with_modified_env({'OOD_USER_SETTINGS_FILE' => settings_file}) do
        visit files_url(Rails.root.to_s)
        tr = find('a', exact_text: 'config').ancestor('tr')
        tr.find('button.dropdown-toggle').click
        wait_for_favorites_reload { tr.find('.add-favorite').click }

        assert_selector('#favorites li', count: 4)
        within(find('#favorites a', text: Rails.root.join('config')).ancestor('div.input-group')) do
          assert_selector('a.rename-favorite')
          assert_selector('button.bg-danger')
        end

        # Add second favorite
        tr = find('a', exact_text: 'test').ancestor('tr')
        tr.find('button.dropdown-toggle').click
        wait_for_favorites_reload { tr.find('.add-favorite').click }

        assert_selector('#favorites li', count: 5)
        within(find('#favorites a', text: Rails.root.join('test')).ancestor('div.input-group')) do
          assert_selector('a.rename-favorite')
          assert_selector('button.bg-danger')
        end

        exp_yaml = {'files_favorites' => [
          {'title' => '', 'path' => Rails.root.join('config').to_s},
          {'title' => '', 'path' => Rails.root.join('test').to_s}
        ]}.to_yaml
        assert_equal exp_yaml, File.read(settings_file)

        # Attempt to add duplicate
        tr = find('a', exact_text: 'config').ancestor('tr')
        tr.find('button.dropdown-toggle').click
        tr.find('.add-favorite').click

        error_msg = "Error occurred when attempting to add file favorite: Favorite already exists for path \"#{Rails.root.join('config')}\"."
        assert_selector('.alert-danger', text: "#{error_msg} Custom favorites have not been updated")
        assert_selector('#favorites li', count: 5)
        assert_selector('#favorites a', text: Rails.root.join('config'), count: 1)
        
        assert_equal exp_yaml, File.read(settings_file)
      end
    end
  end

  test 'renaming files favorites' do
    Dir.mktmpdir do |dir|
      stub_system_favorites(dir)
      settings_file = File.join(dir, '.user_settings.txt')
      existing_yaml = {'files_favorites' => [
        {'title' => '', 'path' => Rails.root.join('config').to_s},
        {'title' => '', 'path' => Rails.root.join('test').to_s}
      ]}.to_yaml
      File.write(settings_file, existing_yaml)
      with_modified_env({'OOD_USER_SETTINGS_FILE' => settings_file}) do
        Singleton.__init__(UserCustomization)
        visit files_url('/')
        within(find('#favorites a', text: Rails.root.join('test').to_s).ancestor('div.input-group')) do
          find('a.rename-favorite').click
        end

        find('#files_input_modal_input').set('Custom Title')
        wait_for_favorites_reload { find('#files_input_modal_ok_button').click }

        assert_selector('#favorites div.input-group', text: 'Custom Title')
        exp_yaml = {'files_favorites' => [
          {'title' => '', 'path' => Rails.root.join('config').to_s},
          {'title' => 'Custom Title', 'path' => Rails.root.join('test').to_s}
        ]}.to_yaml
        assert_equal exp_yaml, File.read(settings_file)
      end
    end
  end

  test 'deleting files favorites' do
    Dir.mktmpdir do |dir|
      stub_system_favorites(dir)
      settings_file = File.join(dir, '.user_settings.txt')
      existing_yaml = {'files_favorites' => [
        {'title' => 'Custom Title', 'path' => Rails.root.join('config').to_s},
        {'title' => 'Custom Title', 'path' => Rails.root.join('app').to_s}
      ]}.to_yaml
      File.write(settings_file, existing_yaml)
      with_modified_env({'OOD_USER_SETTINGS_FILE' => settings_file}) do
        Singleton.__init__(UserCustomization)
        visit files_url('/')

        assert_selector("#favorites li", count: 5)
        accept_alert("Are you sure you want to delete your shortcut to #{Rails.root.join('config')}?") do
          find("#favorites a[href='#{files_path(Rails.root.join('config').to_s)}']", text: 'Custom Title')
            .ancestor('div.input-group')
            .find('button.bg-danger').click
        end
        
        refute_selector("#favorites a[href='#{files_path(Rails.root.join('config').to_s)}']", text: 'Custom Title')
        assert_selector("#favorites li", count: 4)
        exp_yaml = {'files_favorites' => [{'title' => 'Custom Title', 'path' => Rails.root.join('app').to_s}]}.to_yaml
        assert_equal exp_yaml, File.read(settings_file)
      end
    end
  end

  test 'custom favorite action buttons tile below path when narrow (regression #6168)' do
    Dir.mktmpdir do |dir|
      stub_system_favorites(dir)
      settings_file = File.join(dir, '.user_settings.txt')
      File.write(settings_file, {
        'files_favorites' => [
          { 'title' => 'Custom Favorite Shortcut', 'path' => Rails.root.join('config').to_s }
        ]
      }.to_yaml)

      with_modified_env({ 'OOD_USER_SETTINGS_FILE' => settings_file }) do
        Singleton.__init__(UserCustomization)
        original_size = page.current_window.size

        page.current_window.resize_to(992, 1024)
        visit files_url(Rails.root.to_s)

        group = find('#favorites a', text: 'Custom Favorite Shortcut').ancestor('div.favorite-item')
        path_link = group.find('a.favorite-path')
        actions = group.find('.favorite-actions')
        rename_btn = actions.find('a.rename-favorite')
        delete_btn = actions.find('button.bg-danger')

        assert path_link.rect.y < rename_btn.rect.y,
               'expected favorite action buttons to tile below the path when narrow'
        assert_in_delta rename_btn.rect.y, delete_btn.rect.y, 2,
                        'expected edit and delete to wrap together on the same row'
        assert_in_delta path_link.rect.width, actions.rect.width, 2,
                        'expected action buttons to fill the favorite path width'
        assert_in_delta rename_btn.rect.width, delete_btn.rect.width, 2,
                        'expected edit and delete buttons to be equal width'

        page.current_window.resize_to(1400, 1024)
        visit files_url(Rails.root.to_s)

        group = find('#favorites a', text: 'Custom Favorite Shortcut').ancestor('div.favorite-item')
        path_link = group.find('a.favorite-path')
        rename_btn = group.find('a.rename-favorite')

        assert_in_delta path_link.rect.y, rename_btn.rect.y, 2,
                        'expected favorite action buttons to stay beside the path when wide'

        page.current_window.resize_to(*original_size)
      end
    end
  end

  test 'reports errors and catches them before saving' do
    Dir.mktmpdir do |dir|
      stub_system_favorites(dir)
      settings_file = File.join(dir, '.user_settings.txt')
      existing_yaml = {'files_favorites' => [
        {'title' => '', 'path' => Rails.root.join('config').to_s},
        {'title' => '', 'path' => Rails.root.join('test').to_s}
      ]}.to_yaml
      File.write(settings_file, existing_yaml)
      with_modified_env({'OOD_USER_SETTINGS_FILE' => settings_file}) do
        Singleton.__init__(UserCustomization)
        # Can't find favorite error
        UserCustomization.instance.stubs(:find_favorite).returns(nil)
        visit files_url('/')
        # try rename
        within(find('#favorites a', text: Rails.root.join('test').to_s).ancestor('div.input-group')) do
          find('a.rename-favorite').click
        end
        find('#files_input_modal_input').set('Custom Title')
        find('#files_input_modal_ok_button').click
        error = "Could not find favorite with path \"#{Rails.root.join('test')}\"."
        assert_selector('.alert-danger', text: "Error occurred when attempting to rename file favorite: #{error} Custom favorites have not been updated")
        assert_equal existing_yaml, File.read(settings_file)
        find('.alert-danger .btn-close').click
        refute_selector('.alert-danger')
        # try delete
        accept_alert("Are you sure you want to delete your shortcut to #{Rails.root.join('config')}?") do
          find("#favorites a", text: Rails.root.join('config').to_s)
            .ancestor('div.input-group')
            .find('button.bg-danger').click
        end
        assert_selector('.alert-danger', text: "Failed to delete favorite with path \"#{Rails.root.join('config')}\". Custom favorites have not been updated")
        assert_equal existing_yaml, File.read(settings_file)
      end
    end
  end
end
