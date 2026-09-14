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
      base_paths.map do |prefix, path_config|
        target = path_config[:path]
        if target.directory? && target.executable? && target.readable?
          target.children.select {|c| validate_ownership?(c, path_config[:owner]) }.map do |d|
            router = new(d.basename, prefix: prefix)
            app = OodApp.new(router)
            app.batch_connect_app? ? BatchConnect::App.new(router: router) : app
          end.select(&:directory?)
            .select(&:accessible?)
            .reject(&:hidden?)
            .reject(&:backup?)
        else
          []
        end
      end.flatten
    end
  end

  def initialize(name, prefix: nil)
    @name = name.to_s
    @owner = prefix || :sys
    @caption = I18n.t('dashboard.system_apps_caption')
    @category = ""
  end

  def token
    "#{type}/#{name}"
  end

  def self.base_paths
    { 
      :sys => {
        path: base_path,
        owner: nil,
      }
    }.merge(configured_paths)
  end

  def self.base_path
    Pathname.new("/var/www/ood/apps/sys")
  end

  def self.defines?(prefix)
    base_paths.keys.include?(prefix)
  end

  def type
    owner
  end

  def url
    "/pun/#{token}"
  end

  def path
    @path ||= self.class.base_paths.dig(owner, :path)&.join(name)
  end

  private 

  def self.configured_paths
    Configuration.external_apps_config.to_h do |c|
      incomplete = [c[:path], c[:owner], c[:prefix]].map(&:to_s).any?(&:empty?)
      c[:path] = Pathname.new(c[:path])
      valid_path = c[:path].exist? && c[:path].absolute?
      next unless !incomplete && valid_path

      [c[:prefix].to_sym, c.except(:prefix)]
    end
  end

  def self.validate_ownership?(path, owner)
    PosixFile.username_from_cache(path.stat.uid) == owner || owner == nil
  end
end
