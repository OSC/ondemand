class DevRouter
  attr_reader :name, :owner, :caption, :category

  def initialize(name, owner=OodSupport::Process.user.name)
    @name = name.to_s
    @owner = owner
    @caption = "Sandbox App"
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

  def self.base_path(owner: OodSupport::Process.user.name)
    Configuration.dev_apps_root_path
  end

  def base_path
    self.class.base_path(owner: owner)
  end

  def type
    :dev
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
