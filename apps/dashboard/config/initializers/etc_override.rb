require 'etc'

module Etc
  OVERSIZED_GID_OVERRIDE = Process.gid > 60_000 ? {
    Process.gid => "mac.user.group"
  } : {}

  Group = Struct.new(:name, :passwd, :gid, :mem) unless const_defined?(:Group)

  class << self
    alias_method :original_getgrgid, :getgrgid

    def getgrgid(gid)
      if (name = OVERSIZED_GID_OVERRIDE[gid])
        # Build a Struct::Group that looks like a real result
        Group.new(name, "*", gid, [])
      else
        original_getgrgid(gid)
      end
    end
  end
end