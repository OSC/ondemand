class WhitelistPolicy
  attr_reader :whitelist

  def initialize(whitelist)
    @whitelist = whitelist
  end

  # @raises ArgumentError if any whitelist path or permitted? argument
  #         has the form ~user/some/path where user doesn't exist
  def permitted?(path)
    whitelist.blank? || whitelist.any?{ |parent| child?(Pathname.new(parent), Pathname.new(path)) }
  end

  # Determine if child is a subpath of parent
  #
  # If the relative path from the child to the supposed parent includes '..'
  # then child is not a subpath of parent
  #
  # @param parent [Pathname]
  # @param child [Pathname]
  # @return Boolean
  def child?(parent, child)
    ! child.expand_path.relative_path_from(
      parent.expand_path
    ).each_filename.to_a.include?(
      '..'
    )
  end
end
