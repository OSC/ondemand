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
      with_modified_env({ 'OOD_USER_SETTINGS_FILE' => File.join(dir, '.user_settings.txt') }) do
        Singleton.__init__(UserCustomization)
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
  end

  test 'custom favorites append to system favorites' do
    Dir.mktmpdir do |dir|
      with_modified_env({'OOD_USER_SETTINGS_FILE' => File.join(dir, '.user_settings.txt')}) do
        Singleton.__init__(UserCustomization)
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

  test 'empty user settings file drops settings cached from a previous file' do
    pollute_user_customization_settings
    use_empty_user_settings_file
    custom_path = Dir.mktmpdir

    UserCustomization.instance.add_files_favorite(custom_path)
    saved = YAML.safe_load(File.read(ENV.fetch('OOD_USER_SETTINGS_FILE')))
    expected = { 'files_favorites' => [{ 'title' => '', 'path' => custom_path }] }
    assert_equal expected, saved
  ensure
    clear_empty_user_settings_file
    FileUtils.remove_entry(custom_path) if custom_path
  end

  private

  def pollute_user_customization_settings
    fixture = Rails.root.join('test/fixtures/file_output/user_settings/saved_settings_menu.yml').to_s
    with_modified_env({ 'OOD_USER_SETTINGS_FILE' => fixture }) do
      Singleton.__init__(UserCustomization)
      settings = UserCustomization.instance.send(:user_settings)
      assert_includes settings.keys, :batch_connect_templates
    end
  end
end
