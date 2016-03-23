#FIXME: temporary till we can include osc-machete gem in this dashboard
# Class that maintains the name and home identifiers of a User.
# Helper methods provided use the Etc module underneath.
#
class User

  attr_reader :name

  # default user is the username of the current process
  #
  # FIXME: is this true? Etc.getpwuid claims to use the default
  # value from the Passwd struct:
  # http://docs.ruby-lang.org/en/2.0.0/Etc.html#Passwd
  # could this ever be different from Process.gid?
  # Should we provide constructors for a User object for the given uid
  # instead of username, or in Process do
  # OSC::Machete::User.new(Etc.getpwuid.name(Process.gid))
  # Or should the default be OSC::Machete::User.from_uid(Process.uid)
  # Is there ever a difference between the two?
  #
  def initialize(username = Etc.getpwuid.name)
    @name = username
  end

  # factory method to produce a User from specified uid
  #
  # @return [User] user for the specified uid
  def self.from_uid(uid)
    self.new Etc.getpwuid(uid).name
  end

  # Determine if user is member of specified group
  #
  # @param [String] group name
  # @return [Boolean] true if user is a member of the specified group
  def member_of_group?(group)
    Etc.getgrnam(group).mem.include?(@name) rescue false
  end

  # get sorted list of group ids that user is part of
  # by inspecting the /etc/group file
  # there is also a ruby impl of this
  #
  # @return [Array] ids of groups that the user is a member of
  def groups
    `id -G $USER`.strip.split.map(&:to_i).uniq.sort
  end

  # get list of projects the user is part of
  # FIXME: OSC specific
  #
  # @return [Array<String>] of projects the user is part of
  def projects
    `id -Gn`.split.grep(/^P./)
  end

  # FIXME: should we be using Pathnames here?
  #
  # Return Pathname for home directory
  # The home directory path of the user.
  #
  # @return [Pathname] The directory path.
  # def home
  #   Pathname.new(Dir.home(@name))
  # end

  # The home directory path of the user.
  #
  # @return [String] path to the home directory.
  def home
    Dir.home(@name)
  end
end
