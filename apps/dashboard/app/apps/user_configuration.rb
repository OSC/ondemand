class UserConfiguration

  def initialize
    @config = ::Configuration.config
  end

  # The dashboard's landing page layout. Defaults to nil.
  def dashboard_layout
    fetch(:dashboard_layout, nil)
  end

  # The configured pinned apps
  def pinned_apps
    fetch(:pinned_apps, [])
  end

  # The length of the "Pinned Apps" navbar menu
  def pinned_apps_menu_length
    fetch(:pinned_apps_menu_length, 6)
  end

  # What to group pinned apps by
  # @return [String, ""] Defaults to ""
  def pinned_apps_group_by
    group_by = fetch(:pinned_apps_group_by, "")

    # FIXME: the user_configuration shouldn't really know the API of
    # OodApp or subclasses. This is a hack because subclasses of OodApp overload
    # the category and subcategory to something new while saving the original.
    # The fix would be to move this knowledge to somewhere more appropriate than here.
    if group_by == 'category' || group_by == 'subcategory'
      "original_#{group_by}"
    else
      group_by
    end
  end

  def profile_links
    fetch(:profile_links, [])
  end

  def profile
    CurrentUser.user_settings[:profile].to_sym if CurrentUser.user_settings[:profile]
  end

  private

  def fetch(key_value, default_value = nil)
    key = key_value ? key_value.to_sym : nil
    profile_config = @config.dig(:profiles, profile) || {}

    # Returns the value if they key is present in the profile, even if the value is nil
    # This is to mimic the Hash.fetch behaviour that only uses the default_value when key is not present
    profile_config.key?(key) ? profile_config[key] : @config.fetch(key, default_value)
  end
end