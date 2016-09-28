# view object for OodApp instance
class AppView
  attr_reader :app, :view_context

  delegate :type, :owner, :url, :manifest, to: :app

  def initialize(app, view_context)
    @app = app

    #FIXME: if we don't need this, don't use it
    @view_context = view_context
  end

  # FIXME:
  def provider_title
    type == :sys ? "OSC" : provider.title
  end

  def provider_username
    type == :sys ? nil : provider.username
  end

  #FIXME: in the manifest we have support for provider
  # but was this ever used? peek at all the shared apps
  def provider
    @provider ||= UserWithSharedApps.new(owner)
  end

  def name
    app.manifest.name.empty? ? app.name : app.manifest.name
  end

  def accessible?
    @accessible ||= app.accessible?
  end

  def description
    markdown(app.manifest.description)
  end

  private

  def markdown(text, show_errors: false)
    RenderManifestMarkdown.renderer.render(text).html_safe
  rescue
    #FIXME: log or handle error in some way?
    #if show_errors

    text
  end
end
