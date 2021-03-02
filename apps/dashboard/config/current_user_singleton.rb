class CurrentUserSingleton
  def groups
    @groups ||= OodSupport::User.new.groups.sort_by(&:id).tap { |groups|
      groups.unshift(groups.delete(OodSupport::Process.group))
    }.map(&:name).grep(/^P./) 
  end

  def user_in_group?(group)
    OodSupport::Process.groups.include?(group.to_s)
  end
end
