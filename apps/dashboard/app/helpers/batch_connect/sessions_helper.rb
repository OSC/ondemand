# Helper for active batch connect sessions.
#
# Note that this module programatically generates the cards for
# active batch connect sessions.
module BatchConnect::SessionsHelper

  def render_connection(session)
    if session.running?
      if session.view
        views = { partial: "custom", locals: { view: session.view, connect: session.connect } }
      else
        if session.vnc?
          views = []
          views << { title: "noVNC Connection",    partial: "novnc",      locals: { connect: session.connect, app_title: session.title } }
          views << { title: "Native Instructions", partial: "native_vnc", locals: { connect: session.connect } } if ENV["ENABLE_NATIVE_VNC"]
        else
          views = { partial: "missing_connection" }
        end
      end
    elsif session.starting?
      views = { partial: "starting" }
    elsif session.queued?
      views = { partial: "queued" }
    elsif session.completed?
      views = { partial: "completed", locals: { session: session } }
    else
      views = { partial: "bad" }
    end

    connection_tabs(session.id, views)
  end

  def render_card_partial(name, session)
    render(partial: "batch_connect/sessions/card/#{name}", locals: { session: session })
  end

  def session_time(session)
    time_limit = session.info.wallclock_limit
    time_used  = session.info.wallclock_time
    if session.starting? || session.running?
      if time_limit && time_used
        [t('dashboard.batch_connect_sessions_stats_time_remaining'), distance_of_time_in_words(time_limit - time_used, 0, false, :only => [:minutes, :hours], :accumulate_on => :hours)] 
      elsif time_used
        [t('dashboard.batch_connect_sessions_stats_time_used'), distance_of_time_in_words(time_used, 0, false, :only => [:minutes, :hours], :accumulate_on => :hours)] 
      end
    else
      if time_limit
        [t('dashboard.batch_connect_sessions_stats_time_requested'), distance_of_time_in_words(time_limit, 0, false, :only => [:minutes, :hours], :accumulate_on => :hours)]
      end
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

  def relaunch(session)
    return unless session.completed?

    batch_connect_app = session.app
    return unless batch_connect_app.valid?

    user_context = session.user_context
    params = batch_connect_app.attributes.map{|attribute| ["batch_connect_session_context[#{attribute.id}]", user_context.fetch(attribute.id, nil)]}.to_h.compact
    title = "#{t('dashboard.batch_connect_sessions_relaunch_title')} #{session.title} #{t('dashboard.batch_connect_sessions_word')}"
    button_to(
      batch_connect_session_contexts_path(token: batch_connect_app.token),
      method: :post,
      class: %w[btn px-1 py-0 btn-outline-dark relaunch full-page-spinner],
      form_class: %w[d-inline relaunch],
      title: title,
      'aria-label': title,
      data: { toggle: "tooltip", placement: "left" },
      params: params
    ) do
      "#{fa_icon('sync', classes: nil, title: nil)}".html_safe
    end
  end

  def edit(session)
    title = t('dashboard.batch_connect_sessions_edit_title', title: session.title)
    button_to(
      new_batch_connect_session_context_path(token: session.token),
      method: :get,
      class: %w[btn px-1 py-0 btn-outline-dark full-page-spinner],
      form_class: %w[d-inline edit-session],
      title: title,
      'aria-label': title,
      data: { toggle: "tooltip", placement: "left" },
      params: {session_id: session.id}
    ) do
      "#{fa_icon('pen', classes: nil, title: nil)}".html_safe
    end
  end

  def cancel_or_delete(session)
    if Configuration.cancel_session_enabled && !session.completed?
      cancel(session)
    else
      delete(session)
    end
  end

  def delete(session)
    title = "#{t('dashboard.batch_connect_sessions_delete_title')} #{session.title} #{t('dashboard.batch_connect_sessions_word')}"
    button_to(
      batch_connect_session_path(session.id),
      method: :delete,
      class: "btn btn-danger float-end btn-delete",
      title: title,
      'aria-label': title,
      data: { confirm: t('dashboard.batch_connect_sessions_delete_confirm'), toggle: "tooltip", placement: "bottom"}
    ) do
      "#{fa_icon('times-circle', classes: nil)} <span aria-hidden='true'>#{t('dashboard.batch_connect_sessions_delete_title')}</span>".html_safe
    end
  end

  def cancel(session)
    title = "#{t('dashboard.batch_connect_sessions_cancel_title')} #{session.title} #{t('dashboard.batch_connect_sessions_word')}"
    button_to(
      batch_connect_cancel_session_path(session.id),
      method: :post,
      class: "btn btn-danger float-end btn-cancel",
      title: title,
      'aria-label': title,
      data: { confirm: t('dashboard.batch_connect_sessions_cancel_confirm'), toggle: "tooltip", placement: "bottom" }
    ) do
      "#{fa_icon('times-circle', classes: nil)} <span aria-hidden='true'>#{t('dashboard.batch_connect_sessions_cancel_title')}</span>".html_safe
    end
  end

  def novnc_link(connect, view_only: false)
    version  = "1.3.0"
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
          content_tag(:ul, class: "nav nav-tabs") do
            tabs.map { |t| t[:title] }.map.with_index do |title, idx|
              content_tag(:li, class: "nav-item #{"active" if idx.zero?}") do
                link_to title, "#c_#{id}_#{idx}", data: { 'bs-toggle': "tab" }, aria: { selected: (true if idx.zero?) }, class: "nav-link #{"active" if idx.zero?}"
              end
            end.join("\n").html_safe
          end
        )
        # content
        concat(
          content_tag(:div, class: "tab-content") do
            tabs.map.with_index do |tab, idx|
              content_tag(:div, id: "c_#{id}_#{idx}", class: "tab-pane ood-appkit markdown #{"active" if idx.zero?}", role: 'tabpanel') do
                render partial: "batch_connect/sessions/connections/#{tab[:partial]}", locals: tab[:locals]
              end
            end.join("\n").html_safe
          end
        )
      end
    end
  end
end
