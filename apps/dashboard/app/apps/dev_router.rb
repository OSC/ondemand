# The router class for all development apps.
class DevRouter
  attr_reader :name, :owner

  def initialize(name, owner=OodSupport::Process.user.name)
    @name = name.to_s
    @owner = owner
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

  def self.base_path(owner: OodSupport::Process.user.name)
    Configuration.dev_apps_root_path
  end

  def base_path
    self.class.base_path(owner: owner)
  end

  def type
    :dev
  end

  def caption
    I18n.t('dashboard.development_apps_caption')
  end

  def category
    "Sandbox Apps"
  end

  def url
    "/pun/dev/#{name}"
  end

  def path
    @path ||= base_path.join(name)
  end

  def token
    "#{type}/#{name}"
  end
end
