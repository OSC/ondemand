# frozen_string_literal: true

class UserCustomization
  include ActiveModel::Model
  include UserSettingStore

  attr_reader :custom_files_favorites

  def initialize
    @custom_files_favorites ||= favorites_from_array(user_settings[:files_favorites].to_a)
  end

  def update_files_favorites(new_favorites)
    if validate_user_favorites(new_favorites)
      @custom_files_favorites = favorites_from_array(new_favorites)
      update_user_settings({ files_favorites: new_favorites })
    end
  end

  def favorite_paths
    OodFilesApp.new.favorite_paths + custom_files_favorites
  end

  private

  def favorites_from_array(favorites)
    favorites.map do |favorite|
      FavoritePath.new(favorite[:url], title: favorite[:title], filesystem: favorite[:filesystem])
    end
  end

  def validate_files_favorites(new_favorites)
    new_favorites.class == Array && new_favorites.all? do |path|
      Dir.exist?(path) && Dir.readable?(path)
    end
  end
end
