module AppHelper
  # FIXME: show_errors is not used
  def manifest_markdown(text, show_errors: false)
    RenderManifestMarkdown.renderer.render(text).html_safe
  rescue
    text
  end
end
