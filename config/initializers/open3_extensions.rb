module Open3Extensions
  def capture3(*cmd, **opts)
    Rails.logger.info "execve = #{cmd.inspect}"
    super
  end
end

Open3.singleton_class.prepend Open3Extensions
