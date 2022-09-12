# Utility class for rendering markdown README files for products.
class ProductReadmeMarkdownRenderer < Redcarpet::Render::HTML
  attr_reader :app_path

  def self.extensions
    {
      autolink: true,
      tables: true,
      strikethrough: true,
      fenced_code_blocks: true,
      no_intra_emphasis: true
    }
  end
  
  def self.render_opts
    {escape_html: true}
  end
  
  def self.renderer(app_path: nil)
    Redcarpet::Markdown.new(self.new(self.render_opts.merge(app_path: app_path)), self.extensions)
  end
  
  # override to customize the default renderer options
  def initialize(opts={})
    super(opts)
    @app_path = opts.fetch(:app_path, nil)
  end

  # open link in new window
  def link(link, title, content)
    link = OodAppkit.files.api(path: @app_path.to_s + '/' + link).to_s if @app_path && relative?(link)
    return "<a href=\"#{link}\" rel=\"noopener\" target=\"_blank\">#{content}</a>" unless id_link?(link)
    return "<a href=\"#{link}\">#{content}</a>"
  end

  def autolink(link_text, link_type)
    if link_type == :email
      "<a href=\"mailto:#{link_text}\" target=\"_top\">#{link_text}</a>"
    else
      link(link_text, link_text, link_text)
    end
  end
  
  def image(link, title, alt_text)
    link = OodAppkit.files.api(path: @app_path.to_s + '/' + link).to_s if @app_path && relative?(link)
    content = "<img src=\"#{link}\" title=\"#{title}\" alt=\"#{alt_text}\" style=\"max-width:100%;\"/>"
    link(link, title, content)
  end
  
  def header(text, header_level)
    "<h#{header_level} id=\"#{title_to_id(text)}\">#{text}</h#{header_level}>"
  end
  
  private
  
  def relative?(path)
    !URI(path).scheme && !URI(path).host && !path.start_with?("/") && !path.start_with?("#")
  end
  
  def id_link?(path)
    !URI(path).scheme && !URI(path).host && URI(path).path == "" && URI(path).fragment != "" && path.start_with?("#")
  end
  
  def title_to_id(text)
    text.downcase.gsub(/[^a-z]+/, '-')
  end
  
end
