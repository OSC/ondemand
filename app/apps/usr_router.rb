class UsrRouter
  attr_reader :name, :owner

  def self.for(owner)
    owner == "sys" ? ::SysRouter.new : ::UsrRouter.new(owner)
  end

  def initialize(name, owner)
    @name = name
    @owner = owner
  end

  def base_path
    Pathname.new "/var/www/ood/apps/usr/#{owner}/gateway"
  end

  def url
    "/pun/usr/#{owner}/#{name}"
  end

  def path
    @path ||= base_path.join(name)
  end
end
