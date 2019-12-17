module BatchConnect::SessionsHelper
  def session_panel(session)
    num_nodes = session.info.allocated_nodes.size
    num_cores = session.info.procs.to_i

    # Generate nice status display
    status = []
    if session.starting? || session.running?
      status << content_tag(:span, pluralize(num_nodes, "node"), class: "badge") unless num_nodes.zero?
      status << content_tag(:span, pluralize(num_cores, "core"), class: "badge") unless num_cores.zero?
    end
    status << "#{status session}"
    status.join(" | ").html_safe
  end

  def link_to_session_host(session)
      session.connect.host ? link_to(
       session.connect.host, OodAppkit.shell.url(
          host: session.connect.host).to_s,
          target: "_blank",
           class: "btn btn-primary btn-sm fas fa-terminal"
      ) : t('dashboard.batch_connect_sessions_stats_undetermined_host')
  end

  def link_to_session_id(session)
    link_to(
          session.id,
          OodAppkit.files.url(path: session.staged_root).to_s,
          target: "_blank"
    )
  end

  def status(session)
    if session.starting?
      "Starting"
    elsif session.running?
      "Running"
    elsif session.queued?
      "Queued"
    elsif session.held?
      "Held"
    elsif session.suspended?
      "Suspended"
    else
      "Undetermined"
    end
  end

  def status_context(session)
    if session.starting?
      "info"
    elsif session.running?
      "success"
    elsif session.queued?
      "default"
    elsif session.held? || session.suspended?
      "danger"
    else
      "warning"
    end
  end

  def delete(session)
    link_to(
      icon("fas", "trash-alt", t('dashboard.batch_connect_sessions_delete_title'), class: "fa-fw"),
      session,
      method: :delete,
      class: "btn btn-danger pull-right btn-delete",
      title: t('dashboard.batch_connect_sessions_delete_hover'),
      data: { confirm: t('dashboard.batch_connect_sessions_delete_confirm'), toggle: "tooltip", placement: "bottom"}
    )
  end

  def novnc_link(connect, view_only: false)
    version  = "1.0.0"
    password = view_only ? connect.spassword : connect.password
    resize   = view_only ? "downscale" : "remote"
    asset_path("noVNC-#{version}/vnc.html?autoconnect=true&password=#{password}&path=rnode/#{connect.host}/#{connect.websocket}/websockify&resize=#{resize}", skip_pipeline: true)
  end

  def session_save_errors(errors)
    capture do
      errors.keys.each do |key|
        case key
        when :submit
          render partial: "batch_connect/sessions/connections/submit", locals: {errors: errors}
        when :stage
          render partial: "batch_connect/sessions/connections/stage", locals: {errors: errors}
        else
          render partial: "batch_connect/sessions/connections/neither_stage_nor_submit", locals: {errors: errors}
        end
      end
    end
  end

  def connection_tabs(id, tabs)
    tabs = Array.wrap(tabs)
    if tabs.any? && tabs.size == 1
        tab = tabs.first
        render partial: "batch_connect/sessions/connections/one_tab", locals: {tab: tab}
    else
      # tabs
      render partial: "batch_connect/sessions/connections/many_tabs", locals: {tabs: tabs, id: id}
    end
  end
end