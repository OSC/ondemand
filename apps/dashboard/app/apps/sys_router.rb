# The router class for all system apps.
class SysRouter
  attr_reader :name, :owner, :caption, :category

  #TODO: consider making SysRouter a subclass of
  # OodAppkit::Url

  # Get array of apps
  #
  # @return [Array<OodApp>] all system apps
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
    @owner = :sys
    @caption = I18n.t('dashboard.system_apps_caption')
    @category = ""
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

  def url
    "/pun/sys/#{name}"
  end

  def path
    @path ||= self.class.base_path.join(name)
  end
end
