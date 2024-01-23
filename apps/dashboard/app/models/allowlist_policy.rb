require 'pathname'

# AllowlistPolicy allows or denies access to directories based off of a configuration.
class AllowlistPolicy
  attr_reader :allowlist

  class Forbidden < StandardError; end

  def self.default
    AllowlistPolicy.new(Configuration.allowlist_paths)
  end

  def initialize(allowlist)
    @allowlist = allowlist
  end

  # @raises ArgumentError if any allowlist path or permitted? argument
  #         has the form ~user/some/path where user doesn't exist
  def permitted?(path)
    real_path = real_expanded_path(path.to_s)
    key = path_to_key(real_path)
    Rails.cache.fetch(key) do
      allowlist.blank? || allowlist.any? { |parent| child?(Pathname.new(parent), real_path) }
    end
  end

  # @raises AllowlistPolicy::Forbidden if path is not permitted by allowlist
  # @raises ArgumentError if any allowlist path or permitted? argument
  #         has the form ~user/some/path where user doesn't exist
  def validate!(path)
    return if permitted?(path.to_s)

    msg = "#{path} does not have an ancestor directory specified in ALLOWLIST_PATH"
    Rails.logger.warn(msg)
    raise AllowlistPolicy::Forbidden, msg
  end

  protected

  def path_to_key(path)
    ino = path.exist? ? path.lstat.ino : nil
    "allowlist_permitted_#{path}_#{ino}"
  end

  # call realpath to ensure symlinks are handled
  def real_expanded_path(path)
    # call realpath to ensure symlinks are resolved
    Pathname.new(path).expand_path.realpath
  rescue SystemCallError
    # path doesn't exist, so we just get absolute version then
    Pathname.new(path).expand_path
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
    !child.expand_path.relative_path_from(
      parent.expand_path
    ).each_filename.to_a.include?(
      '..'
    )
  end
end
