class DevProduct < Product
  class << self
    def all
      DevRouter.apps.map {|a| new(name: a.name, found: true)}
    end

    def find(name)
      raise Product::NotFound unless DevRouter.new(name).path.exist?
      new(name: name, found: true)
    end
  end

  def type
    :dev
  end

  def router
    DevRouter.new(name) if name
  end

  def permissions?
    false
  end
end
