class AppRouter

  attr_reader :type, :name, :owner

  APP_TYPES = [ :sys, :dev, :usr ].freeze

  class << self
    def apps(type = nil)
      apps = routers.map do |router|
        Rails.cache.fetch("app_#{router.token}") do
          OodApp.new(router)
        end
      end

      type.nil? ? apps : apps.select { |a| a.type == type.to_sym }
    end

    def find(token)
      Rails.cache.fetch("app_#{token}") do
        router = router_from_token(token)
        OodApp.new(router)
      end
    end

    def base_path(type, owner: nil)
      case type
      when :sys
        Pathname.new("/var/www/ood/apps/sys")
      when :dev
        Configuration.dev_apps_root_path
      when :usr
        Pathname.new("/var/www/ood/apps/usr/#{owner}/gateway")
      end
    end

    def routers
      @routers ||= APP_TYPES.map do |type|
        if type == :usr
          owners.map do |owner|
            # code smell, passing owner all over the place
            target = self.base_path(type, owner: owner)
            routers_from_dir(target, type, owner: owner)
          end
        else
          target = base_path(type)
          routers_from_dir(target, type)
        end
      end.flatten
    end

    def routers_from_dir(target, type, owner: nil)
      if target.directory? && target.executable? && target.readable?
        target.children.map do |dir| 
          self.new(name: dir.basename, type: type, owner: owner)
        end.select do |router|
          router.directory? && router.accessible?
        end.reject do |router| 
          router.hidden? || router.backup?
        end
      else
        []
      end
    end

    def router_from_token(token)
      type, *app = token.split("/")

      if type == 'usr'
        owner, name, = app
      else
        name, = app
        owner = nil
      end

      new(name: name, type: type, owner: owner)
    end

    def owners
      @owners ||= begin
        p = Pathname.new("/var/www/ood/apps/usr")
        p.readable? ? p.children.map { |p| p.basename.to_s } : []
      end
    end
  end

  def initialize(name: nil, type: nil, owner: nil)
    @name = name.to_s
    @type = type.to_sym
    @owner = owner && owner.to_s

    raise StandardError, 'some message' unless APP_TYPES.include?(@type)
  end

  def path
    @path ||= begin
      base = self.class.base_path(type)
      p = usr? ? "#{base}/#{owner}/#{name}" : "#{base}/#{name}"
      Pathname.new(p)
    end
  end

  def accessible?
    path.executable? && path.readable?
  end

  def directory?
    path.directory?
  end

  def hidden?
    path.basename.to_s.start_with?(".")
  end

  def backup?
    !hidden? && path.basename.to_s.include?(".")
  end

  def token
    usr? ? "#{type}/#{owner}/#{name}" : "#{type}/#{name}"
  end

  def url
    "/pun/#{token}"
  end

  def sys?() type == :sys end
  def dev?() type == :dev end
  def usr?() type == :usr end
end