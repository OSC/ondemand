class User < OodSupport::User

  # other paths to provide links to via file explorer
  # TODO: use this to replace project space and scratch paths
  def other_paths
    @other_paths ||= (project_space_paths + scratch_user_paths)
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
