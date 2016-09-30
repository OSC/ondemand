class UsrRouter
  attr_reader :name, :owner

  def initialize(name, owner=OodSupport::Process.user.name)
    @name = name
    @owner = owner
  end

  def self.apps(owner: OodSupport::Process.user.name)
    base_path(owner: owner).children.map { |d|
      ::OodApp.new(self.new(d.basename, owner))
    }.select { |d|
      d.valid_dir? && d.accessible? && d.manifest.valid?
    }
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
    # ood
    Pathname.new("/var/www/ood/apps/usr").children(false).map(&:to_s)

    # dev
    # Rails.root.join("data", "apps","usr").children(false).map(&:to_s)

    # awesim
    # ["awe0011", "efranz", "jnicklas"]
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
