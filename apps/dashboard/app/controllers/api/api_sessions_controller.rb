class Api::ApiSessionsController < ApiController

  def index
    @sessions = BatchConnect::Session.all
    @sessions.each(&:update_cache_completed!)

    response = @sessions.map do |session|
      create_session_data session
    end

    render json: { items: response }

  rescue Exception => error
    logger.error "action=getSessions user=#{@user} error=#{error}"
    render json: { message: error }, status: :internal_server_error
  end

  def show
    session_id = params[:id]
    if !BatchConnect::Session.exist?(session_id)
      render json: { message: "Not found session_id: #{session_id}" }, status: :not_found
      return
    end

    session = BatchConnect::Session.find(session_id)
    render json: create_session_data(session)
  end

  def create
    if params[:token] == nil || params[:token] == ""
      render json: { message: "missing token" }, status: :bad_request
      return
    end

    app = BatchConnect::App.from_token params[:token]
    if !app.valid?
      render json: { message: app.validation_reason }, status: :bad_request
      return
    end

    success, session = create_session
    if success
      render json: { id: session.id }
    else
      logger.error "action=createSession user=#{@user} errors=#{session.errors.full_messages}"
      render json: { message: "Unable to create session", errors: session.errors.full_messages }, status: :internal_server_error
    end

  rescue Exception => error
    logger.error "action=createSession user=#{@user} error=#{error}"
    render json: { message: "Exception while creating session", errors: error }, status: :internal_server_error
  end

  def destroy
    session_id = params[:id]
    if !BatchConnect::Session.exist?(session_id)
      render json: { message: "Not found sessionId: #{session_id}" }, status: :not_found
      return
    end

    session = BatchConnect::Session.find(session_id)
    if session.destroy
      render json: {}, status: :no_content
    else
      logger.error "action=deleteSession user=#{@user} errors=#{session.errors.full_messages}"
      render json: { message: "Unable to delete session", errors: session.errors.full_messages }, status: :internal_server_error
    end

  rescue Exception => error
    logger.error "action=deleteSession user=#{@user} error=#{error}"
    render json: { message: "Exception while deleting session", errors: error }, status: :internal_server_error
  end

  private

  def create_session_data(session)
    session_data_url = OodAppkit.files.url(path: session.staged_root).to_s
    session_shell_url = OodAppkit.shell.url(host: session.connect.host).to_s if session.running? && session.connect.host
    connect = create_connect_data session

    {
      id: session.id,
      clusterId: session.cluster_id,
      jobId: session.job_id,
      createdAt: session.created_at,
      token: session.token,
      title: session.title,
      info: session.info.to_h,
      status: session.status.to_sym,
      type: session.script_type,
      connect: connect,
      wallClockTimeSeconds: session.info.wallclock_time,
      wallClockLimitSeconds: session.info.wallclock_limit,
      deletedInDays: session.days_till_old,
      sessionDataUrl: session_data_url,
      sessionShellUrl: session_shell_url,
    }
  end

  def create_connect_data(session)
    connect_data = nil
    if session.running?
      connect_data = session.connect.to_h
      if session.view
        connect_data[:url] = parse_form_action(session)
      else
        connect_data[:url] = helpers.novnc_link(session.connect, view_only: false)
      end
    end

    connect_data
  end

  def parse_form_action(session)
    #Render view HTML and get the action URL from the form
    view = OodAppkit.markdown.render(ERB.new(session.view, nil, "-").result(session.connect.instance_eval { binding }))
    view_html = Nokogiri::HTML(view)
    view_html.at("form")["action"]
  rescue => error
    logger.error "action=view_form_action user=#{@user} error=#{error}"
    ""
  end

  def create_session
    session_context = app.build_session_context
    render_format = app.clusters.first.job_config[:adapter] unless app.clusters.empty?
    #Read attributes from payload
    session_context.attributes = params.permit(session_context.attributes.keys)

    cache_file = BatchConnect::Session.dataroot(app.token).tap { |p| p.mkpath unless p.exist? }.join("context.json")
    session = BatchConnect::Session.new

    success = false
    if session.save(app: app, context: session_context, format: render_format)
      # save context to cache file
      cache_file.write(session_context.to_json)
      success = true
    end

    return [success, session]
  end
end
