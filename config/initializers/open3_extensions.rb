module Open3Extensions
  def capture3(*cmd, **opts)
    Rails.logger.error("CMD: #{cmd}")
    super
  end
end

Open3.singleton_class.prepend Open3Extensions
