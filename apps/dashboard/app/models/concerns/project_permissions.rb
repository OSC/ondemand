module ProjectPermissions
  def with_proper_umask(path)
    with_umask(get_umask(path)) do
      yield
    end
  end

  def with_umask(mask)
    old = File.umask(mask)
    yield
  ensure
    File.umask(old)
  end

  def get_umask(path)
    shared?(path) ? 0o007 : 0o077
  end

  def shared?(path)
    !path.to_s.start_with?(CurrentUser.home)
  end
end
