# frozen_string_literal: true

class UserCustomization
  include ActiveModel::Model
  include UserSettingStore
    
  attr_reader :custom_files_favorites

  # supported actions modify customization in a clear way, and return a boolean
  def self.supported_actions
    [:add_files_favorite, :delete_files_favorite, :rename_files_favorite].freeze
  end

  def initialize
    @custom_files_favorites ||= user_settings[:files_favorites].to_a
  end

  def add_files_favorite(favorite_path)
    if validate_favorite_path?(favorite_path)
      @custom_files_favorites << { title: '', path: favorite_path }
      update_favorites
      true
    else
      false
    end
  rescue
    false
  end

  def delete_files_favorite(index)
    removed = @custom_files_favorites.delete_at(index.to_i)
    return false if removed.nil?
    
    update_favorites
    true
  rescue 
    false
  end

  def rename_files_favorite(index, new_title)
  end

  def favorite_paths
    OodFilesApp.new.favorite_paths + favorites_from_array(custom_files_favorites)
  end

  def custom_favorite?(favorite)
    custom_files_favorites.any? do |custom|
      favorite.path.to_s == custom[:path] && favorite.title.to_s == custom[:title]
    end
  end

  private

  def update_favorites
    update_user_settings({ files_favorites: custom_files_favorites })
  end
  
  def favorites_from_array(favorites)
    favorites.map do |favorite|
      title = favorite[:title].to_s.length > 0 ? favorite[:title] : nil
      FavoritePath.new(favorite[:path], title: title)
    end
  end

  def validate_favorite_path?(path)
    File.absolute_path?(path) && File.directory?(path) && File.readable?(path)
  end
end
