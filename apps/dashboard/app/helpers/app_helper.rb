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
    content = displayable_settings(app).map do |attr| 
      "<div class='row'> <dt>#{attr.label}:</dt> <dd>#{attr.value}</dd> </div>" 
    end
    content.empty? ? nil : ['<dl class="app-settings-popup">', content.join('<hr>'), '</dl>'].join
  end

  def displayable_settings?(app)
    !displayable_settings(app).empty?
  end

  private

  def displayable_settings(app)
    app.attributes.select(&:display?).reject{ |a| a.widget == 'password_field' }
  end
end
