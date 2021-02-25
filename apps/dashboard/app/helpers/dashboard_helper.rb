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
      tag.img src: uri, alt: "logo", height: Configuration.logo_height, style: "margin-bottom: 10px"
    else # default logo image
      image_tag("OpenOnDemand_stack_RGB.svg", alt: "logo", height: "85px", style: "margin-bottom: 10px")
    end
  end

  def invalid_clusters
    @invalid_clusters ||= OodCore::Clusters.new(OodAppkit.clusters.select { |c| not c.valid? })
  end

  def pinned_apps?
    !Router.pinned_apps.empty?
  end
end
