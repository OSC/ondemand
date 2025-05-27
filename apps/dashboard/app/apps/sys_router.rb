# The router class for all system apps.
class SysRouter
  attr_reader :name, :owner, :caption, :category

  #TODO: consider making SysRouter a subclass of
  # OodAppkit::Url

  # Get array of apps
  #
  # @return [Array<OodApp>] all system apps
  def self.apps
    Rails.cache.fetch('sys_apps', expires_in: 6.hours) do
      target = base_path
      if target.directory? && target.executable? && target.readable?
        target.children.map do |d|
          router = new(d.basename)
          app = OodApp.new(router)
          app.batch_connect_app? ? BatchConnect::App.new(router: router) : app
        end.select(&:directory?)
           .select(&:accessible?)
           .reject(&:hidden?)
           .reject(&:backup?)
      else
        []
      end
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
