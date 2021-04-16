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

  def xdmod?
    Configuration.xdmod_integration_enabled?
  end

  def pinned_apps?
    @pinned_apps.present?
  end

  def motd?
    @motd.present?
  end

  def landing_page_layout
    #FIXME: should sanitize the landing_page_layout or cast somethings to Array in the upper layers
    Configuration.landing_page_layout || default_landing_page_layout
  end

  def render_widget(widget)
    begin
      render partial: widget.to_s
    rescue SyntaxError, StandardError => e
      render partial: "widget_error", locals: { error: e, widget: widget.to_s }
    end
  end

  private

  def default_landing_page_layout
    if xdmod?
      if pinned_apps? || motd?
        left_column = { width: 8, widgets: ['pinned_apps', 'motd'] }
        right_column = { width: 4, widgets: ['xdmod_widget_job_efficiency', 'xdmod_widget_jobs'] }
      else
        left_column = { width: 4, widgets: ['xdmod_widget_job_efficiency'] }
        right_column = { width: 8, widgets: ['xdmod_widget_jobs'] }
      end
    elsif pinned_apps? && motd?
      left_column = { width: 8, widgets: ['pinned_apps'] }
      right_column = { width: 4, widgets: ['motd'] }
    else
      left_column = { width: 12, widgets: ['pinned_apps', 'motd'] }
      right_column = nil
    end

    { rows: [{ columns: [left_column, right_column].compact }] }
  end

end
