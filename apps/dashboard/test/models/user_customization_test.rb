# frozen_string_literal: true

require 'test_helper'

class UserCustomizationTest < ActiveSupport::TestCase
  def teardown
    Singleton.__init__(UserCustomization)
  end

  test 'supported actions are real methods' do
    UserCustomization.supported_actions.each do |method|
      assert UserCustomization.instance.respond_to?(method)
    end
  end

  test 'favorite_paths include system favorites' do
    Dir.mktmpdir do |dir|
      path1 = File.join(dir, 'fav_dir_1')
      path2 = File.join(dir, 'other_dir')
      favorites = [path1, path2].map do |d| 
        FileUtils.mkdir_p(d)
        FavoritePath.new(d)
      end
      OodFilesApp.any_instance.stubs(:candidate_favorite_paths).returns(favorites)

      assert UserCustomization.favorite_paths == favorites
    end
  end

  test 'custom favorites append to system favorites' do
    Dir.mktmpdir do |dir|
      with_modified_env({'OOD_USER_SETTINGS_FILE' => File.join(dir, '.user_settings.txt')}) do
        path1 = File.join(dir, 'fav_dir_1')
        path2 = File.join(dir, 'other_dir')
        favorites = [path1, path2].map do |d| 
          FileUtils.mkdir_p(d)
          FavoritePath.new(d)
        end
        OodFilesApp.any_instance.stubs(:candidate_favorite_paths).returns(favorites)

        custom_path = File.join(dir, 'custom_dir')
        FileUtils.mkdir_p(custom_path)
        UserCustomization.instance.add_files_favorite(custom_path)
        exp_favorites = favorites.clone.push(FavoritePath.new(custom_path))
        assert_equal UserCustomization.favorite_paths.map(&:to_s), exp_favorites.map(&:to_s)
      end
    end
  end
end
