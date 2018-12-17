module PagesHelper
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

  def whitelist
    ::Rails.application.config.whitelist_paths
  end

  def is_path_whitelisted?
    whitelist.empty? || whitelist.any?{|parent| child?(parent, @pathname)}
  end
end
