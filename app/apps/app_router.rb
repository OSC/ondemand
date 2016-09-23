# must respond to:
# #path, #type, #url, #owner
# FIXME: probably #name too -- so we don't duplicate that knowledge
# FIXME: path should return Pathname objects
class AppRouter
  attr_reader :url, :path, :type

  def initialize(path)
    @path = Pathname.new(path)
    @url = "#"
    @type = :path
  end

  def owner
    @owner ||= Etc.getpwuid(path.stat.uid).name
  end
end
