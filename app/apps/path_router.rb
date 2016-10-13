# A special router to use to instantiate an OodApp
# object if all you have is the path to the app
class PathRouter
  attr_reader :category, :caption, :url, :type, :path

  def initialize(path)
    @caption = nil
    @category = "App"
    @url = "#"
    @type = :path
    @path = Pathname.new(path)
  end

  def owner
    @owner ||= Etc.getpwuid(path.stat.uid).name
  end
end
