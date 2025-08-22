# Helper for /apps pages.
module AppHelper
  # FIXME: show_errors is not used
  def manifest_markdown(text, show_errors: false)
    RenderManifestMarkdown.renderer.render(text).html_safe
  rescue
    text
  end

  def caption_app?(app)
    app.type == :dev || app.type == :usr
  end

  def row_id(url)
    url.gsub("/", "-").slice(1, url.length)
  end

  def recent_settings(app)
    app.attributes.select(&:display?).map { |attr| "#{attr.label}: #{attr.value}" }.join(' <br> ')
  end

  def displayable_settings?(app)
    !recent_settings(app).empty?
  end
end
