module Open3Extensions
  def capture3(*cmd, **opts)
    # FIXME: Taking educated guess on what Splunk wants in the logs
    Rails.logger.error(%[execve="#{cmd.to_s.gsub('"', '\"')}"])
    super
  end
end

Open3.singleton_class.prepend Open3Extensions
