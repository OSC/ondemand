class SysRouter
  attr_reader :name

  #TODO: consider making SysRouter a subclass of
  # OodAppkit::Url

  # Get array of apps
  #
  # @return [Array<OodApp>] all apps
  def self.apps
    target = base_path
    if target.directory? && target.executable? && target.readable?
      target.children.map { |d| OodApp.new self.new(d.basename) }
        .select(&:directory?)
        .select(&:accessible?)
        .reject(&:hidden?)
        .reject(&:backup?)
    else
      []
    end
  end

  def initialize(name)
    @name = name.to_s
  end

  def token
    "#{type}/#{name}"
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

  def caption
    "System Installed App"
  end

  def category
    "System Installed Apps"
  end

  def url
    "/pun/sys/#{name}"
  end

  def path
    @path ||= self.class.base_path.join(name)
  end
end
