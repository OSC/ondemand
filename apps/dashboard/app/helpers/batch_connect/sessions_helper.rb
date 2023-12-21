# Helper for active batch connect sessions.
#
# Note that this module programatically generates the cards for
# active batch connect sessions.
module BatchConnect::SessionsHelper
  def session_panel(session)
    content_tag(:div, id: "id_#{session.id}", class: "card session-panel mb-4", data: { id: session.id, hash: session.to_hash }) do
      concat(
        content_tag(:div, class: "card-heading") do
          content_tag(:h5, class: "card-header overflow-auto alert-#{status_context(session)}") do
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
                relaunch(status, session)
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
          concat content_tag(:div, cancel_or_delete(session), class: 'float-right')
          concat host(session)
          concat created(session)
          concat session_time(session)
          concat id(session)
          concat support_ticket(session) unless @user_configuration.support_ticket.empty?
          concat display_choices(session)
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
    render(partial: 'batch_connect/sessions/card/created', locals: { session: session })
  end

  def session_time_helper(session)
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

  def session_time(session)
    render(partial: 'batch_connect/sessions/card/session_time', locals: { session: session })
  end

  def host(session)
    render(partial: 'batch_connect/sessions/card/host', locals: { session: session })
  end

  def id(session)
    render(partial: 'batch_connect/sessions/card/id', locals: { session: session })
  end

  def support_ticket(session)
    render(partial: 'batch_connect/sessions/card/support_ticket', locals: { session: session })
  end

  def display_choices(session)
    render(partial: 'batch_connect/sessions/card/display_choices', locals: { session: session })
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

  def relaunch(status_array, session)
    return unless session.completed?

    batch_connect_app = session.app
    return unless batch_connect_app.valid?

    user_context = session.user_context
    params = batch_connect_app.attributes.map{|attribute| ["batch_connect_session_context[#{attribute.id}]", user_context.fetch(attribute.id, '')]}.to_h
    title = "#{t('dashboard.batch_connect_sessions_relaunch_title')} #{session.title} #{t('dashboard.batch_connect_sessions_word')}"
    status_array << button_to(
      batch_connect_session_contexts_path(token: batch_connect_app.token),
      method: :post,
      class: %w[btn px-1 py-0 btn-outline-dark relaunch],
      form_class: %w[d-inline relaunch],
      title: title,
      'aria-label': title,
      data: { toggle: "tooltip", placement: "left" },
      params: params
    ) do
      "#{fa_icon('sync', classes: nil, title: '')}".html_safe
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
      class: "btn btn-danger float-right btn-delete",
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
      class: "btn btn-danger float-right btn-cancel",
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
                link_to title, "#c_#{id}_#{idx}", data: { toggle: "tab" }, aria: { selected: (true if idx.zero?) }, class: "nav-link #{"active" if idx.zero?}"
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
