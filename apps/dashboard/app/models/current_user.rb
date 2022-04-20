# frozen_string_literal: true

# The CurrentUser class represents the current user on the system from Etc.
# It has a name, a home directory, gid, uid and so on.
#
# It is a singleton for the simple reason that this is ran in a single
# user context (i.e., the Per User Nginx).  And for convienence to do stuff
# like User.home instead of User.new.home or OodSupport::User.new.home.
class CurrentUser
  include Singleton

  class << self
    delegate :name, :uid, :gid, :gecos, :dir, :shell, to: :instance
    delegate :primary_group, :home, to: :instance
  end

  attr_reader :pwuid
  delegate :name, :uid, :gid, :gecos, :dir, :shell, to: :pwuid
  alias_method :home, :dir

  def initialize
    @pwuid ||= Etc.getpwuid
  end

  def primary_group
    @primary_group ||= Etc.getgrgid(gid).name
  end
end
