# frozen_string_literal: true

require 'etc'
require 'singleton'
require 'active_support/core_ext/module/delegation'

# The CurrentUser class represents the current user on the system from Etc.
# It has a name, a home directory, gid, uid and so on.
#
#
# It is a singleton for the simple reason that this is ran in a single
# user context (i.e., the Per User Nginx).  And for convenience to do stuff
# like User.home instead of User.new.home or OodSupport::User.new.home.
class CurrentUser
  include Singleton

  class << self
    delegate :name, :uid, :gid, :gecos, :dir, :shell, to: :instance
    delegate :primary_group, :primary_group_name, :group_names, :groups, to: :instance

    alias_method :home, :dir
  end

  attr_reader :pwuid
  delegate :name, :uid, :gid, :gecos, :dir, :shell, to: :pwuid

  def initialize
    @pwuid = Etc.getpwuid
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

      # let's guarantee that the first item in this list is the primary group
      groups = Process.groups
      groups.delete(primary_group.gid)
      groups.unshift(primary_group.gid).map { |gid| Etc.getgrgid(gid) }
    end
  end
end
