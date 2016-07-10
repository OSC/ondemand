#FIXME: temporary till we can include osc-machete gem in this dashboard
# Class that maintains the name and home identifiers of a User.
# Helper methods provided use the Etc module underneath.
#
class User < OSC::Machete::User

  # currently, only wiag user's are developers
  def developer?
    @developer ||= member_of_group?("wiag")
  end

  # FIXME: apps that display should display based on whether the user has access
  # i.e. rx to the app directory. We should treat "production apps" just like
  # any other app, instead of calling out those who have ruby access by
  # explicitly checking if they are in the ruby group.
  def has_ruby_access?
    @has_ruby_access ||= member_of_group?("ruby")
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

  def get_scratch_user_paths
    paths = projects.map { |p| Pathname.new("/fs/scratch/#{p}") }.select {|p| p.directory? && p.readable? && p.executable? }

    userdir = Pathname.new("/fs/scratch/#{name}")
    paths << userdir if userdir.directory? && userdir.readable? && userdir.executable?

    paths
  end
end
