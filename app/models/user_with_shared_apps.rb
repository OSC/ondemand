# FIXME: temporary - do we need this?
class UserWithSharedApps
  attr_accessor :username

  def initialize(username)
    @username = username
  end

  def me?
    Etc.getpwuid.name == username
  end

  def title
    title = (Etc.getpwnam(username).gecos || username)
    title = "AweSim" if username == "awe0011"
    title
  end

  def <=>(a)
    # higher weight will be < than
    # lower - to push priority elements to the
    # front of a list sorted in ascending order
    if weight < a.weight
      1
    elsif weight > a.weight
      -1
    else
      title <=> a.title
    end
  end

  # TODO: move this into AweSim::App#<=> or similar?
  # for sorting users with apps
  def weight
    if username == "awe0011"
      2
    else
      1
    end
  end

  def apps
    # filter shared apps list so only those appear that
    # are both URL accessible and have a vaild manifest
    @apps ||= DashboardRouter.new(username).shared_apps
      .select {|app| app.url_accessible_to_current_user? && app.manifest.valid? }
  end
end