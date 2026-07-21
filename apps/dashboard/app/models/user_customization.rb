# frozen_string_literal: true

class UserCustomization
  include ActiveModel::Model
  include UserSettingStore

  attr_reader :custom_files_favorites

  def initialize
    @custom_files_favorites ||= user_settings[:files_favorites].to_a
  end

  def update_files_favorites(new_favorites)
    if validate_files_favorites(new_favorites)
      @custom_files_favorites = new_favorites
      update_user_settings({ files_favorites: new_favorites })
    end
  end

  def favorite_paths
    OodFilesApp.new.favorite_paths + favorites_from_array(custom_files_favorites)
  end

  private

  def favorites_from_array(favorites)
    favorites.map do |favorite|
      title = favorite[:title].to_s.length > 0 ? favorite[:title] : nil
      FavoritePath.new(favorite[:path], title: title)
    end
  end

  def validate_files_favorites(new_favorites)
    new_favorites.class == Array && new_favorites.all? do |favorite|
      path = favorite['path']
      File.directory?(path) && File.readable?(path)
    end
  end
end
