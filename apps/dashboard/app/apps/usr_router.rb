# The router class for all user shared apps.
class UsrRouter
  attr_reader :name, :owner

  def initialize(name, owner=OodSupport::Process.user.name)
    @name = name.to_s
    @owner = owner
  end

  # The Internationalizable caption for display in an icon or text.
  # In two forms, with full name if it can get it from Etc, otherwise
  # the short form.
  #
  #     "Shared by aokley"
  #     "Shared by Annie Oakley (aokley)"
  #
  # @return [String] human readable owner string
  def caption
    if owner_title == owner
      I18n.t('dashboard.shared_apps_caption_short', owner: owner)
    else
      I18n.t('dashboard.shared_apps_caption', owner: owner, owner_title: owner_title)
    end
  end

  def category
    owner_title
  end

  def owner_title
    return @owner_title if defined?(@owner_title)

    @owner_title ||= (Etc.getpwnam(owner).gecos || owner)
  rescue
    @owner_title = owner
  end

  # Get array of all apps from specified owners
  #
  # @param owners [String, Array<String>] owner or owners to get apps for
  # @return [Array<OodApp>] array of apps that the specified owner(s) have
  def self.all_apps(owners:)
    Array(owners).map { |o| UsrRouter.apps(owner: o) }.flatten
  end

  # Get array of apps for specified owner
  #
  # @param owner [String] username of user to get apps for
  # @return [Array<OodApp>] all apps owner has shared that user has access to
  def self.apps(owner: OodSupport::Process.user.name)
    Rails.cache.fetch("usr_apps_#{owner}", expires_in: 6.hours) do
      target = base_path(owner: owner)
      if target.directory? && target.executable? && target.readable?
        target.children.map do |d|
          router = new(d.basename, owner)
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

  def self.base_path(owner: OodSupport::Process.user.name)
    Pathname.new "/var/www/ood/apps/usr/#{owner}/gateway"
  end

  def self.owners
    owners = []

    target = Pathname.new("/var/www/ood/apps/usr")
    owners = target.children(false).map(&:to_s) if target.directory? && target.executable? && target.readable?

    owners
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

  def token
    "#{type}/#{owner}/#{name}"
  end
end
