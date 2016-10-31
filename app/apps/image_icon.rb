class ImageIcon
  attr_reader :path, :url

  def initialize(path, url)
    @path = Pathname.new(path)
    @url = url
  end

  def file?
    @path.file?
  end

  def html
    %Q( <img class="app-icon" src="#{url}" title="#{path}"> ).html_safe
  end
end
