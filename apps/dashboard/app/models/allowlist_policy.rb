# frozen_string_literal: true

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
    return true if allowlist.blank?

    real_path = real_expanded_path(path.to_s)
    key = path_to_key(real_path)
    Rails.cache.fetch(key) do
      allowlist.any? { |parent| child?(Pathname.new(parent), real_path) }
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

  # Determine if child is a subpath of parent.
  # This does not access the filesystem, so symlinks should be evaluated before this.
  #
  # @param parent [Pathname]
  # @param child [Pathname]
  # @return Boolean
  def child?(parent, child)
    # Expand both paths to evaluate any potential ".." components to be able to compare them as strings.
    p = parent.expand_path.to_s
    c = child.expand_path.to_s
    # Child path if it is same as parent path, or has additional components after "/".
    c.start_with?(p) && (c.size == p.size || c[p.size] == '/')
  end
end
