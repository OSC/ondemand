# The router class for all external apps.
class ExtRouter
  attr_reader :name, :owner, :caption, :category

  # Get array of apps
  #
  # @return [Array<OodApp>] all external apps
  def self.apps
    Rails.cache.fetch('ext_apps', expires_in: 6.hours) do
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
    @owner = :ext
    @caption = I18n.t('dashboard.system_apps_caption')
    @category = 'External Apps'
  end

  def token
    "#{type}/#{name}"
  end

  def self.base_path
    Pathname.new(Configuration.external_app_path.to_s).tap do |path|
      blank = Pathname.new('')
      return blank unless path.exist? && path.absolute?

      owner = PosixFile.username_from_cache(path.stat.uid)
      return blank unless owner == Configuration.external_app_owner
    end
  end

  def type
    :ext
  end

  def url
    "/pun/ext/#{name}"
  end

  def path
    @path ||= self.class.base_path.join(name)
  end
end
