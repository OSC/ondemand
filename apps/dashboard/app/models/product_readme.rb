# Class representing the README file of a product.
class ProductReadme
  
  def initialize(product)
    @path = Pathname.glob(product.app.path.join("readme*"), File::FNM_CASEFOLD).first || product.app.path.join("README.md")
  end
  
  def html
    if @path.basename.to_s =~ /.*.md|.*.markdown/i
        content = ProductReadmeMarkdownRenderer.renderer(app_path: @path.parent).render(@path.read).html_safe
    else
        content = "<pre>#{@path.read}</pre>"
    end
    "<div id=\"readme\">#{content}</div>".html_safe
  end
  
  def exist?
    @path.file? && @path.readable?
  end
  
  def title
    @path.basename
  end
  
  # include Rails.application.routes.url_helpers
  
  def edit_url
    OodAppkit.editor.edit(path: @path)
  end
  
end