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
    raise AllowlistPolicy::Forbidden, "#{path} does not have an ancestor directory specified in ALLOWLIST_PATH" unless permitted?(path.to_s)
  end

  protected

  def path_to_key(path)
    ino = path.exist? ? path.lstat.ino : nil
    "allowlist_permitted_#{path}_#{ino}"
  end

  # call realpath to ensure symlinks are handled
  def real_expanded_path(path)
    path = Pathname.new(path).expand_path

    # if it exsists, then you can just call realpath
    return Pathname.new(path).expand_path.realpath if path.exist?

    real_expanded_path_not_exist(path)
  end

  # if a path doesn't exist yet, then we have the find the
  # first parent that _does_ exist and cast _it_ to the realpath
  # to find what's a symlink and what's not.
  def real_expanded_path_not_exist(path)
    first_real_parent = '/'
    parent_to_replace = '/'

    path.ascend do |parent_path|
      if parent_path.exist?
        first_real_parent = parent_path.expand_path.realpath
        parent_to_replace = parent_path
        break
      end
    end

    path = path.to_s.gsub(parent_to_replace.to_s, first_real_parent.to_s)
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
