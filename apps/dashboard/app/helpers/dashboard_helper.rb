module DashboardHelper
  #FIXME: copied from awesim-dev-dashboard
  def markdown(text)
    RenderManifestMarkdown.renderer.render(text)
  rescue
    text
  end

  def logo_image_tag(url)
    if url
      uri = Addressable::URI.parse(url)
      uri.query_values = (uri.query_values || {}).merge({timestamp: Time.now.to_i})
      logo_css_attributes = "margin-bottom: 10px;"

      if uri.extname == ".svg"
        logo_css_attributes.concat("height: #{Configuration.logo_height if Configuration.logo_height}px;")
        %(<img src="#{uri}" alt="logo" style="#{ logo_css_attributes }" />).html_safe
      else
        %(<img src="#{uri}" alt="logo" style="#{ logo_css_attributes }" />).html_safe
      end
    else # default logo image
      image_tag("OpenOnDemand_stack_RGB.svg", alt: "logo", height: "85", style: "margin-bottom: 10px")
    end
  end

  def invalid_clusters
    @invalid_clusters ||= OodCore::Clusters.new(OodAppkit.clusters.select { |c| not c.valid? })
  end
end
