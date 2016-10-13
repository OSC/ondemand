class UsrRouter
  attr_reader :name, :owner

  def initialize(name, owner=OodSupport::Process.user.name)
    @name = name
    @owner = owner
  end

  # Get a human readable explanation of the owner of this app such as:
  #
  #     "Shared by Eric Franz (efranz)"
  #
  # @return [String] human readable owner string
  def caption
    "Shared by #{owner_title} (#{owner})"
  end

  def category
    owner_title
  end

  def owner_title
    @owner_title ||= (Etc.getpwnam(owner).gecos || owner)
  end

  # Get array of all apps from specified owners
  #
  # @param owners [String, Array<String>] owner or owners to get apps for
  # @return [Array<OodApp>] array of apps that the specified owner(s) have
  def self.all_apps(owners:)
    Array(owners).map { |o| UsrRouter.apps(owner: o) }.flatten
  end

  # Get array of apps for specified owner
  #
  # @param owner [String] username of user to get apps for
  # @param require_manifest [Boolean] if true, exclude apps that don't have a valid manifest
  # @return [Array<OodApp] all valid apps owner has shared that user has access to
  def self.apps(owner: OodSupport::Process.user.name, require_manifest: true)
    target = base_path(owner: owner)
    if target.directory? && target.executable? && target.readable?
      target.children.map { |d|
        ::OodApp.new(self.new(d.basename, owner))
      }.select { |d|
        d.valid_dir? && d.accessible? && (!require_manifest || d.manifest.valid?)
      }
    else
      []
    end
  end

  def self.base_path(owner: OodSupport::Process.user.name)
    # ood
    Pathname.new "/var/www/ood/apps/usr/#{owner}/gateway"

    # dev
    # Pathname.new Rails.root.join("data", "apps","usr", owner)

    # awesim
    # Pathname.new(Dir.home).join("awesim_shared_apps")
  end

  def self.owners
    owners = []

    # ood
    target = Pathname.new("/var/www/ood/apps/usr")
    owners = target.children(false).map(&:to_s) if target.directory? && target.executable? && target.readable?

    # dev
    # owners = Rails.root.join("data", "apps","usr").children(false).map(&:to_s)

    # awesim
    # owners = ["awe0011", "efranz", "jnicklas"]

    owners
  end

  def base_path
    self.class.base_path(owner: owner)
  end

  def url
    "/pun/usr/#{owner}/#{name}"
  end

  def path
    @path ||= base_path.join(name)
  end

  def type
    :usr
  end
end
