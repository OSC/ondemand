class User < OodSupport::User

  # currently, only wiag user's are developers
  def developer?
    @developer ||= in_group?("wiag")
  end

  # FIXME: apps that display should display based on whether the user has access
  # i.e. rx to the app directory. We should treat "production apps" just like
  # any other app, instead of calling out those who have ruby access by
  # explicitly checking if they are in the ruby group.
  def has_ruby_access?
    @has_ruby_access ||= in_group?("ruby")
  end

  # project space is in /nfs/gpfs/PZS0645 where the directory name is the name
  # of the project; so return paths to directories that the user has rx to
  def project_space_paths
    @project_space_paths ||= projects.map { |p| Pathname.new("/fs/project/#{p}") }.select {|p| p.directory? && p.readable? && p.executable? }
  end

  # return [] or paths to directories recommended by users to create i.e.
  # /fs/scratch/PROJECTNAME or /fs/scratch/username
  def scratch_user_paths
    @scratch_user_paths ||= get_scratch_user_paths
  end

  # FIXME: wish this was a Pathname object... alias to go to OodSupport::User
  def home
    dir
  end

  private

  def projects
    groups.map(&:name).grep(/^P./)
  end

  def get_scratch_user_paths
    paths = projects.map { |p| Pathname.new("/fs/scratch/#{p}") }.select {|p| p.directory? && p.readable? && p.executable? }

    userdir = Pathname.new("/fs/scratch/#{name}")
    paths << userdir if userdir.directory? && userdir.readable? && userdir.executable?

    paths
  end
end
