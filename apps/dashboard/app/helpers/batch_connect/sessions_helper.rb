module BatchConnect::SessionsHelper
  def session_panel(session)
    content_tag(:div, id: session.id, class: "card panel-#{status_context(session)} session-panel", data: { hash: session.to_hash }) do
      concat(
        content_tag(:div, class: "card-heading") do
          content_tag(:h5, class: "card-header alert-#{status_context(session)}") do
            concat link_to(content_tag(:span, session.title, class: "card-text alert-#{status_context(session)}"), new_batch_connect_session_context_path(token: session.token))
            concat tag.span(" (#{session.job_id})", class: 'card-text')
            concat(
              content_tag(:div, class: "float-right") do
                num_nodes = session.info.allocated_nodes.size
                num_cores = session.info.procs.to_i

                # Generate nice status display
                status = []
                if session.starting? || session.running?
                  status << content_tag(:span, pluralize(num_nodes, "node"), class: "badge badge-#{status_context(session)} badge-pill") unless num_nodes.zero?
                  status << content_tag(:span, pluralize(num_cores, "core"), class: "badge badge-#{status_context(session)} badge-pill") unless num_cores.zero?
                end
                status << "#{status session}"
                tag.span(status.join(" | ").html_safe, class: "card-text")
              end
            )
          end
        end
      )
      concat(
        content_tag(:div, class: "card-body") do
          yield
        end
      )
    end
  end

  def session_view(session)
    capture do
      concat(
        content_tag(:div) do
          concat content_tag(:div, delete(session), class: 'float-right')
          concat host(session)
          concat created(session)
          concat time(session)
          concat id(session)
          safe_concat custom_info_view(session) if session.app.session_info_view
        end
      )
      concat content_tag(:div) { yield }
    end
  end

  def custom_info_view(session)
    concat tag.hr
    content_tag(:div) do
      concat session.render_info_view

      if session.render_info_view_error_message
        content_tag(:div, class: "alert alert-danger", role: "alert") do
          concat tag.p session.render_info_view_error_message
        end
      end
    end
  end

  def created(session)
    content_tag(:p) do
      concat content_tag(:strong, t('dashboard.batch_connect_sessions_stats_created_at'))
      concat " "
      concat Time.at(session.created_at).localtime.strftime("%Y-%m-%d %H:%M:%S %Z")
    end
  end

  def time(session)
    time_limit = session.info.wallclock_limit
    time_used  = session.info.wallclock_time

    content_tag(:p) do
      if session.starting? || session.running?
        if time_limit && time_used
          concat content_tag(:strong, t('dashboard.batch_connect_sessions_stats_time_remaining'))
          concat " "
          concat distance_of_time_in_words(time_limit - time_used, 0, false, :only => [:minutes, :hours], :accumulate_on => :hours)
        elsif time_used
          concat content_tag(:strong, t('dashboard.batch_connect_sessions_stats_time_used'))
          concat " "
          concat distance_of_time_in_words(time_used, 0, false, :only => [:minutes, :hours], :accumulate_on => :hours)
        end
      else  # not starting or running
        if time_limit
          concat content_tag(:strong, t('dashboard.batch_connect_sessions_stats_time_requested'))
          concat " "
          concat distance_of_time_in_words(time_limit, 0, false, :only => [:minutes, :hours], :accumulate_on => :hours)
        end
      end
    end
  end

  def host(session)
    if ::Configuration.ood_bc_ssh_to_compute_node
      content_tag(:p) do
        concat content_tag(:strong, t('dashboard.batch_connect_sessions_stats_host'))
        concat " "
        concat(
          session.connect.host ? link_to(
            session.connect.host, OodAppkit.shell.url(
              host: session.connect.host).to_s,
              target: "_blank",
              class: "btn btn-primary btn-sm fas fa-terminal"
            ) : t('dashboard.batch_connect_sessions_stats_undetermined_host')
        )
      end if session.running?
    else
      content_tag(:p) do
        concat content_tag(:strong, t('dashboard.batch_connect_sessions_stats_host'))
        concat " "
        concat session.connect.host || t('dashboard.batch_connect_sessions_stats_undetermined_host')
      end if session.running?
    end
  end

  def id(session)
    content_tag(:p) do
      concat content_tag(:strong, t('dashboard.batch_connect_sessions_stats_session_id'))
      concat " "
      concat(
        link_to(
          session.id,
          OodAppkit.files.url(path: session.staged_root).to_s,
          target: "_blank"
        )
      )
    end
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
    elsif session.completed?
      "Completed"
    else
      "Undetermined"
    end
  end

  def status_context(session)
    if session.starting?
      "primary"
    elsif session.running?
      "success"
    elsif session.queued?
      "info"
    elsif session.completed?
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
      class: "btn btn-danger float-right btn-delete",
      title: t('dashboard.batch_connect_sessions_delete_hover'),
      data: { confirm: t('dashboard.batch_connect_sessions_delete_confirm'), toggle: "tooltip", placement: "bottom"}
    )
  end

  def novnc_link(connect, view_only: false)
    version  = "1.1.0"
    password = view_only ? connect.spassword : connect.password
    resize   = view_only ? "downscale" : "remote"
    asset_path("noVNC-#{version}/vnc.html?autoconnect=true&password=#{password}&path=rnode/#{connect.host}/#{connect.websocket}/websockify&resize=#{resize}", skip_pipeline: true)
  end

  def connection_tabs(id, tabs)
    tabs = Array.wrap(tabs)
    if tabs.any? && tabs.size == 1
      # hr + content
      capture do
        tab = tabs.first
        concat tag.hr
        concat(
          content_tag(:div, class: "ood-appkit markdown") do
            render partial: "batch_connect/sessions/connections/#{tab[:partial]}", locals: tab[:locals]
          end
        )
      end
    else
      # tabs
      content_tag(:div) do
        # menu
        concat(
          content_tag(:ul, class: "nav nav-tabs", id: id) do
            tabs.map { |t| t[:title] }.map.with_index do |title, idx|
              content_tag(:li, class: "nav-item #{"active" if idx.zero?}") do
                link_to title, "##{id}_#{idx}", data: { toggle: "tab" }, aria: { selected: (true if idx.zero?) }, class: "nav-link #{"active" if idx.zero?}"
              end
            end.join("\n").html_safe
          end
        )
        # content
        concat(
          content_tag(:div, class: "tab-content", id: "#{id}Content") do
            tabs.map.with_index do |tab, idx|
              content_tag(:div, id: "#{id}_#{idx}", class: "tab-pane ood-appkit markdown #{"active" if idx.zero?}", role: 'tabpanel') do
                render partial: "batch_connect/sessions/connections/#{tab[:partial]}", locals: tab[:locals]
              end
            end.join("\n").html_safe
          end
        )
      end
    end
  end
end
