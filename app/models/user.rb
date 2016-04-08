#FIXME: temporary till we can include osc-machete gem in this dashboard
# Class that maintains the name and home identifiers of a User.
# Helper methods provided use the Etc module underneath.
#
class User < OSC::Machete::User
  # project space is in /nfs/gpfs/PZS0645 where the directory name is the name
  # of the project; so return paths to directories that the user has rx to
  def project_space_paths
    @project_space_paths ||= projects.map { |p| Pathname.new("/nfs/gpfs/#{p}") }.select {|p| p.directory? && p.readable? && p.executable? }
  end

  #TODO: it might be a nice feature, but websvcs08 does not have access to /fs/lustre
  # return [] or paths to directories recommended by users to create i.e.
  # /fs/lustre/PROJECTNAME or /fs/lustre/username
  # def lustre_user_paths
  #   @lustre_user_paths ||= get_lustre_user_paths
  # end

  # private

  # def get_lustre_user_paths
  #   paths = projects.map { |p| Pathname.new("/fs/lustre/#{p}") }.select {|p| p.directory? && p.readable? && p.executable? }

  #   userdir = Pathname.new("/fs/lustre/#{name}")
  #   paths << userdir if userdir.directory? && userdir.readable? && userdir.executable?

  #   paths
  # end

end
