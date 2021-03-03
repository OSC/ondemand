class CurrentUserSingleton
  def groups
    @groups ||= OodSupport::Process.groups.map(&:name) 
  end

  def user_in_group?(group)
    OodSupport::Process.groups.include?(group.to_s)
  end
end
