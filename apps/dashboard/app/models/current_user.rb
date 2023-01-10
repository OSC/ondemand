# frozen_string_literal: true

# The CurrentUser class represents the current user on the system from Etc.
# It has a name, a home directory, gid, uid and so on.
#
# It is used to manage the user settings like profile.
# These are read and stored using the ::Configuration.dataroot directory. See user_settings_path
#
# It is a singleton for the simple reason that this is ran in a single
# user context (i.e., the Per User Nginx).  And for convienence to do stuff
# like User.home instead of User.new.home or OodSupport::User.new.home.
class CurrentUser
  include Singleton

  class << self
    delegate :name, :uid, :gid, :gecos, :dir, :shell, to: :instance
    delegate :home, :user_settings, :update_user_settings, to: :instance
    delegate :primary_group, :primary_group_name, :group_names, :groups, to: :instance
  end

  attr_reader :pwuid
  delegate :name, :uid, :gid, :gecos, :dir, :shell, to: :pwuid
  alias_method :home, :dir

  def initialize
    @pwuid = Etc.getpwuid
    @user_settings = read_user_settings
  end

  def primary_group
    @primary_group ||= Etc.getgrgid(gid)
  end

  def primary_group_name
    @primary_group_name ||= primary_group.name
  end

  def group_names
    @group_names ||= groups.map(&:name)
  end

  def groups
    @groups ||= begin
      
      # let's guarentee that the first item in this list is the primary group
      groups = Process.groups
      groups.delete(primary_group.gid)
      groups.unshift(primary_group.gid).map { |gid| Etc.getgrgid(gid) }
    end
  end

  def user_settings
    @user_settings.clone
  end

  def update_user_settings(new_user_settings)
    @user_settings.deep_merge!(new_user_settings.deep_symbolize_keys)
    save_user_settings
  end

  private
  def read_user_settings
    user_settings = {}
    return user_settings unless user_settings_path.exist?

    begin
      yml = YAML.safe_load(user_settings_path.read) || {}
      user_settings = yml.deep_symbolize_keys
    rescue => e
      Rails.logger.error("Can't read or parse settings file: #{user_settings_path} because of error #{e}")
    end

    user_settings
  end

  def save_user_settings
    # Ensure there is a directory to write the user settings file
    user_settings_path.dirname.tap { |p| p.mkpath unless p.exist? }
    File.open(user_settings_path.to_s, "w") { |file| file.write(@user_settings.deep_stringify_keys.to_yaml) }
  end

  def user_settings_path
    Pathname.new(::Configuration.dataroot).join(::Configuration.user_settings_file)
  end
end
