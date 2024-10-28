# frozen_string_literal: true

require 'redcarpet'
# require './dashboard_router'

# Custom markdown renderer for the manifest
# file attributes.
class RenderManifestMarkdown < Redcarpet::Render::HTML
  attr_reader :no_links

  def self.extensions
    {
      autolink:           true,
      tables:             true,
      strikethrough:      true,
      fenced_code_blocks: true,
      no_intra_emphasis:  true
    }
  end

  def self.renderer
    @markdown ||= Redcarpet::Markdown.new(self, extensions)
  end

  def self.renderer_for_disabled_apps
    @markdown_disabled = Redcarpet::Markdown.new(new(no_links: true), extensions)
  end

  # override to customize the default renderer options
  def initialize(opts = {})
    super opts.merge(escape_html: true)

    @no_links = opts.fetch(:no_links, false)
  end

  # open link in new window
  def link(link, _title, content)
    if no_links
      content
    else
      # "<a href=\"#{DashboardRouter.normalize(link)}\" target=\"_top\">#{content}</a>"
      "<a href=\"#{link}\">#{content}</a>"
    end
  end

  def autolink(link_text, link_type)
    if link_type == :email
      "<a href=\"mailto:#{link_text}\" target=\"_top\">#{link_text}</a>"
    else
      link(link_text, link_text, link_text)
    end
  end
end
