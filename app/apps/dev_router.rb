class DevRouter
  attr_reader :name, :owner

  def initialize(name, owner=OodSupport::Process.user.name)
    @name = name
    @owner = owner
  end

  def self.apps(owner: OodSupport::Process.user.name)
    base_path(owner: owner).children.map { |d|
      ::OodApp.new(self.new(d.basename, owner))
    }.select(&:valid_dir?).select(&:accessible?)
  end

  def self.base_path(owner: OodSupport::Process.user.name)
    Pathname.new "#{Dir.home(owner)}/#{ENV['OOD_PORTAL']}/dev"
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
end
