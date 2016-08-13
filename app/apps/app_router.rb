class AppRouter
  attr_accessor :url, :path, :owner, :type

  def initialize(path: "/dev/null", owner: nil)
    @url = "#"
    @path = Pathname.new(path)
    @type = :path
    @owner = owner || Etc.getpwuid(workdir.stat.uid).name
  end

  def owner
  end

  TYPES = {
    sys: {
      basepath: "/var/www/ood/apps/sys"
      url: "/pun/sys/%{name}"
      path: "%{base_path}/%{name}"
    },
    usr: {
      basepath: "/var/www/ood/apps/usr/%{owner}/gateway",
      url: "/pun/usr/%{owner}/%{app}",
      path: "%{base_path}/%{name}"
    },
    # the problem with this approach...
    # dev apps are in the home directory of the user :-(
    # and based on OOD_PORTAL
    dev: {
      basepath: "/var/www/ood/apps/usr/%{owner}/gateway",
      url: "/pun/usr/%{owner}/%{app}",
      path: "%{base_path}/%{name}"
    }
  }

  def self.router_for(type:, name:, owner:)
    app = AppRouter.new
  end

  def self.router_for(path:)
    app = AppRouter.new
    app.url = "#"
    app.type = "path"
  end
end
