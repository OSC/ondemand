require 'redcarpet'

class RenderInlineTextMarkdown < Redcarpet::Render::HTML
  def self.extensions
    {
      autolink: true,
      tables: true,
      strikethrough: true,
      fenced_code_blocks: true,
      no_intra_emphasis: true
    }
  end

  def self.renderer
    @markdown ||= Redcarpet::Markdown.new(self, self.extensions)
  end

  def paragraph(text)
    text
  end
end
