module DashboardHelper
  #FIXME: copied from awesim-dev-dashboard
  def markdown(text)
    RenderManifestMarkdown.renderer.render(text)
  rescue
    text
  end

  def logo_image_tag(url)
    return "" unless url

    uri = Addressable::URI.parse(url)
    uri.query_values = (uri.query_values || {}).merge({timestamp: Time.now.to_i})

    %Q(<img alt="logo" src="#{uri}" />).html_safe
  end
end
