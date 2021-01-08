module ERBRenderHelper
  # To add in more common use cases in ERB rendering when needed
  def groups
    @groups ||= OodSupport::User.new.groups.map(&:name)
  end

  def user_in_group?(group)
    groups.include?(group.to_s)
  end
end
