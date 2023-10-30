# frozen_string_literal: true

# A Product class for development apps.
class DevProduct < Product
  class << self
    def all
      router.apps.map { |a| new(name: a.name, found: true) }
    end

    def find(name)
      raise Product::NotFound unless router.new(name).path.exist?

      new(name: name, found: true)
    end

    def router
      DevRouter
    end
  end

  def type
    :dev
  end

  def router
    self.class.router.new(name) if name
  end

  def permissions?
    false
  end
end
