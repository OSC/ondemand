class SysRouter
  attr_reader :name

  #TODO: consider making SysRouter a subclass of
  # OodAppkit::Url

  # TODO: consider memoizing this for the duration of the request
  # one way would be to instantiate a new SysRouter and then use that same
  # instance
  def self.app_exists?(name)
    OodApp.new(SysRouter.new(name)).valid_dir?
  end

  def self.apps
    base_path.children.map { |d|
      # ::OodApp.new(self.new(d.basename, owner))
      ::OodApp.new(self.new(d.basename))
    }.select(&:valid_dir?).select(&:accessible?)
  end

  def initialize(name)
    @name = name
  end

  def self.base_path
    Pathname.new "/var/www/ood/apps/sys"
  end

  def type
    :sys
  end

  def owner
    :sys
  end

  def url
    "/pun/sys/#{name}"
  end

  def path
    @path ||= self.class.base_path.join(name)
  end
end
