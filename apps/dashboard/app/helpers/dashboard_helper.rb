# Helper for the dashboard (root) page(s).
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
      tag.img(src: uri, alt: "logo", height: @user_configuration.dashboard_logo_height, class: 'py-2')
    else # default logo image
      image_tag("OpenOnDemand_stack_RGB.svg", alt: "logo", height: "85", class: 'py-2')
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

  def dashboard_layout
    #FIXME: should sanitize the landing_page_layout or cast somethings to Array in the upper layers
    @user_configuration.dashboard_layout || default_dashboard_layout
  end

  def render_widget(widget)
    begin
      render partial: "widgets/#{widget}"
    rescue SyntaxError, StandardError => e
      render_error_widget(e, widget.to_s)
      # rubocop:disable Lint/RescueException - because these can throw all sorts of errors.
    rescue Exception => e
      # rubocop:enable Lint/RescueException
      render_error_widget(e, widget.to_s)
    end
  end

  private

  def render_error_widget(error, widget_name)
    render(partial: 'shared/widget_error', locals: { error: error, widget: widget_name })
  end

  def default_dashboard_layout
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

    { rows: [recently_used_row, { columns: [left_column, right_column].compact }] }
  end

  def recently_used_row
    {
      columns: [{
        width:   12,
        widgets: ['recently_used_apps']
      }]
    }
  end

  def render_motd_rss_item(item)
    return '' unless item.description

    content = if Configuration.motd_render_html?
                item.description.html_safe
              else
                sanitize(item.description)
              end

    content_tag(:div, content, data: { 'motd-rss-item': true })
  end
end
