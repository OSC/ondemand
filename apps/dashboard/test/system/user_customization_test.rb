# frozen_string_literal: true

require 'application_system_test_case'

class UserCustomizationTest < ApplicationSystemTestCase
  def stub_system_favorites(dir)
    path1 = File.join(dir, 'fav_dir_1')
    path2 = File.join(dir, 'other_dir')
    favorites = [path1, path2].map do |d|
      FileUtils.mkdir_p(d)
      FavoritePath.new(d)
    end
    OodFilesApp.any_instance.stubs(:candidate_favorite_paths).returns(favorites)
  end

  test 'adding files favorites' do
    Dir.mktmpdir do |dir|
      stub_system_favorites(dir)
      settings_file = File.join(dir, '.user_settings.txt')
      with_modified_env({'OOD_USER_SETTINGS_FILE' => settings_file}) do
        visit files_url(Rails.root.to_s)
        tr = find('a', exact_text: 'config').ancestor('tr')
        tr.find('button.dropdown-toggle').click
        tr.find('.add-favorite').click

        assert_selector('#favorites li', count: 4)
        within(find('#favorites a', text: Rails.root.join('config')).ancestor('div.input-group')) do
          assert_selector('a.rename-favorite')
          assert_selector('button.bg-danger')
        end
        
        exp_yaml = {'files_favorites' => [{'title' => '', 'path' => Rails.root.join('config').to_s}]}.to_yaml
        assert_equal exp_yaml, File.read(settings_file)
      end
    end
  end

  test 'renaming files favorites' do
    Dir.mktmpdir do |dir|
      stub_system_favorites(dir)
      settings_file = File.join(dir, '.user_settings.txt')
      existing_yaml = {'files_favorites' => [{'title' => '', 'path' => Rails.root.join('config').to_s}]}.to_yaml
      File.write(settings_file, existing_yaml)
      with_modified_env({'OOD_USER_SETTINGS_FILE' => settings_file}) do
        visit files_url('/')
        within(find('#favorites a', text: Rails.root.join('config').to_s).ancestor('div.input-group')) do
          find('a.rename-favorite').click
        end

        find('#files_input_modal_input').set('Custom Title')
        find('#files_input_modal_ok_button').click

        assert_selector('#favorites div.input-group', text: 'Custom Title')
        exp_yaml = {'files_favorites' => [{'title' => 'Custom Title', 'path' => Rails.root.join('config').to_s}]}.to_yaml
        assert_equal exp_yaml, File.read(settings_file)
      end
    end
  end

  test 'deleting files favorites' do
    Dir.mktmpdir do |dir|
      stub_system_favorites(dir)
      settings_file = File.join(dir, '.user_settings.txt')
      existing_yaml = {'files_favorites' => [
        {'title' => '', 'path' => Rails.root.join('config').to_s},
        {'title' => 'Custom Title', 'path' => Rails.root.join('config').to_s},
        {'title' => 'Custom Title', 'path' => Rails.root.join('app').to_s}
      ]}.to_yaml
      File.write(settings_file, existing_yaml)
      with_modified_env({'OOD_USER_SETTINGS_FILE' => settings_file}) do
        visit files_url('/')

        assert_selector("#favorites li", count: 6)
        find("#favorites a[href='#{files_path(Rails.root.join('config').to_s)}']", text: 'Custom Title')
          .ancestor('div.input-group')
          .find('button.bg-danger').click
        
        refute_selector("#favorites a[href='#{files_path(Rails.root.join('config').to_s)}']", text: 'Custom Title')
        assert_selector("#favorites li", count: 5)
        exp_yaml = {'files_favorites' => [
          {'title' => '', 'path' => Rails.root.join('config').to_s},
          {'title' => 'Custom Title', 'path' => Rails.root.join('app').to_s}
        ]}.to_yaml
        assert_equal exp_yaml, File.read(settings_file)
      end
    end
  end
end