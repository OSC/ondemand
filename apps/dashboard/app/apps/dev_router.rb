# DevRouter is the Router for development apps.
class DevRouter
  attr_reader :name, :owner, :caption, :category

  def initialize(name, owner=OodSupport::Process.user.name)
    @name = name.to_s
    @owner = owner
    @caption = I18n.t('dashboard.development_apps_caption')
    @category = "Sandbox Apps"
  end

  # Get array of apps for specified owner
  #
  # @param owner [String] username of user to get apps for
  # @return [Array<OodApp>] all apps owner has access to in sandbox
  def self.apps(owner: OodSupport::Process.user.name)
    target = base_path(owner: owner)
    if target.directory? && target.executable? && target.readable?
      target.children.map { |d| OodApp.new self.new(d.basename, owner) }
        .select(&:directory?)
        .select(&:accessible?)
        .reject(&:hidden?)
        .reject(&:backup?)
    else
      []
    end
  end

  # Get the base path from with all development apps reside.
  #
  # @param [String] The name of the app owner (not used).
  # @return [Pathname] The base path from with all development apps reside.
  def self.base_path(owner: OodSupport::Process.user.name)
    Configuration.dev_apps_root_path
  end

  # Get the base path from with all development apps reside.
  #
  # @param [String] The name of the app owner (not used).
  # @return [Pathname] The base path from with all development apps reside.
  def base_path
    self.class.base_path(owner: owner)
  end

  # Get the type of router this is.
  #
  # @return [Symbol] The type of router this is.
  def type
    :dev
  end

  # Get the relative URL for this router.
  #
  # @return [String] The relative URL for this router.
  def url
    "/pun/dev/#{name}"
  end

  # Get the directory path for the app this router is attached to.
  #
  # @return [Pathname] The directory path for the app this router is attached to.
  def path
    @path ||= base_path.join(name)
  end

  # Get this router's token.
  #
  # @return [String] This routers token.
  def token
    "#{type}/#{name}"
  end
end
