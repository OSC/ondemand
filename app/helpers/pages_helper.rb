module PagesHelper
  # Determine if target is a child of root
  # @param root [Pathname]
  # @param target [Pathname]
  # @return Boolean
  def child?(root, target)
    abs_root = root.expand_path.to_s.split('/')
    abs_target = target.expand_path.to_s.split('/')
    
    (abs_root & abs_target) == abs_root
  end

  def whitelist
    ::Rails.application.config.whitelist_paths
  end

  def is_path_whitelisted?
    whitelist.empty? || whitelist.any?{|parent| child?(parent, @pathname)}
  end
end
