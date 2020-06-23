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
      content_tag(:div, class: "row") do
        content_tag(:div, class: "col-sm-6 col-md-6 col-lg-6") do
          image_tag("#{uri}", class: "img-responsive", alt: "logo").html_safe
        end
      end
    else # default logo image
      image_tag("OpenOnDemand_stack_RGB.svg", alt: "logo", height: "85", style: "margin-bottom: 10px")
    end
  end

  def invalid_clusters
    @invalid_clusters ||= OodCore::Clusters.new(OodAppkit.clusters.select { |c| not c.valid? })
  end
end
