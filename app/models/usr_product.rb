class UsrProduct < Product
  class << self
    def all
      UsrRouter.apps.map {|a| new(name: a.name, found: true)}
    end

    def find(name)
      raise Product::NotFound unless UsrRouter.new(name).path.exist?
      new(name: name, found: true)
    end
  end

  def type
    :usr
  end

  def router
    UsrRouter.new(name) if name
  end
end
