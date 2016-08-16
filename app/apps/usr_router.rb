class UsrRouter
  attr_reader :name, :owner

  def initialize(name, owner)
    @name = name
    @owner = owner
  end

  def self.apps(owner:)
    base_path(owner: owner).children.map { |d|
      ::OodApp.new(self.new(d.basename, owner))
    }.select(&:valid_dir?).select(&:accessible?)
  end

  def self.base_path(owner:)
    Pathname.new "/var/www/ood/apps/usr/#{owner}/gateway"
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
end
