namespace :batch_connect do
  desc "Generate new batch connect session"
  task new_session: :environment do
    # Read in user settings
    app = ENV["BC_APP_TOKEN"] || abort("Missing environment variable BC_APP_TOKEN")
    fmt = ENV["BC_RENDER_FORMAT"]
    ctx = $stdin.read

    # Initialize objects
    app   = BatchConnect::App.from_token app
    app.load_form_config
    fmt ||= app.cluster.job_config[:adapter] if app.cluster
    session_ctx = app.build_session_context
    session_ctx.from_json(ctx)

    # Generate new session
    session = BatchConnect::Session.new
    unless session.save(app: app, context: session_ctx, format: fmt)
      error_msg = "Failed to launch session with following errors:\n\n"
      session.errors.full_messages.each do |error|
        error_msg += "  - #{error.gsub(/\n/, "\n    ")}\n\n"
      end
      abort error_msg
    end
  end
end
