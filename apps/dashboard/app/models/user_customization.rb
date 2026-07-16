# frozen_string_literal: true

class UserCustomization
  include UserSettingStore

  attr_reader :files_favorites
  
  def initialize
    @files_favorites ||= user_settings[:files_favorites].to_a
  end

  def update_files_favorites(new_favorites)
    if validate_user_favorites(new_favorites)
      @files_favorites = new_favorites
      update_user_settings({ files_favorites: new_favorites })
    end
  end

  private

  def validate_files_favorites(new_favorites)
    new_favorites.class == Array && new_favorites.all? do |path|
      File.exist?(path) && File.readable?(path)
    end
  end
end
