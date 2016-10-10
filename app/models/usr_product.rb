class UsrProduct < Product
  class << self
    def all
      router.apps(require_manifest: false).map {|a| new(name: a.name, found: true)}
    end

    def find(name)
      raise Product::NotFound unless router.new(name).path.exist?
      new(name: name, found: true)
    end

    def router
      UsrRouter
    end
  end

  def type
    :usr
  end

  def router
    self.class.router.new(name) if name
  end
end
