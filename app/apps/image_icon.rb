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
    %Q( <img src="#{url}" width="100" height="100" title="#{path}" ).html_safe
  end
end
