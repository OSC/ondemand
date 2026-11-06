# frozen_string_literal: true

class UserCustomization
  include Singleton
  include UserSettingStore
    
  attr_reader :custom_files_favorites

  class << self
    # supported actions modify customization in a clear way, and raise if they fail
    def supported_actions
      [:add_files_favorite, :delete_files_favorite, :rename_files_favorite].freeze
    end
    
    def favorite_paths
      OodFilesApp.new.favorite_paths + favorites_from_array(instance.custom_files_favorites)
    end

    def custom_favorite?(favorite)
      instance.custom_files_favorites.any? do |custom|
        favorite.path.to_s == custom[:path] && favorite.title.to_s == custom[:title]
      end
    end

    private

    def favorites_from_array(favorites)
      favorites.map do |favorite|
        title = favorite[:title].to_s.length > 0 ? favorite[:title] : nil
        FavoritePath.new(favorite[:path], title: title)
      end
    end
  end

  def initialize
    @custom_files_favorites ||= user_settings[:files_favorites].to_a
  end

  def add_files_favorite(favorite_path)
    validate_favorite_path!(favorite_path)
    @custom_files_favorites << { title: '', path: favorite_path }
    update_favorites
  end

  def delete_files_favorite(path)
    removed = @custom_files_favorites.delete(find_favorite(path))
    raise "Failed to delete favorite with path #{path.inspect}" if removed.nil?
    
    update_favorites
  end

  def rename_files_favorite(json)
    args = JSON.parse(json)
    favorite = find_favorite(args['path'])
    raise "Could not find favorite with path #{args['path'].inspect}" if favorite.nil?
  
    favorite[:title] = args['name']
    update_favorites
  end

  private

  def update_favorites
    update_user_settings({ files_favorites: custom_files_favorites })
  end

  def find_favorite(path)
    custom_files_favorites.find {|f| f[:path] == path}
  end

  def validate_favorite_path!(path)
    raise "Favorite already exists for path #{path}" unless find_favorite(path).nil?

    msg = "Invalid path specified: #{path}"
    raise msg unless File.absolute_path?(path) && File.directory?(path) && File.readable?(path)
  end
end
