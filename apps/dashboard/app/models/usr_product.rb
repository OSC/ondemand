# frozen_string_literal: true

# A Product class for shard (usr) apps.
class UsrProduct < Product
  validate :assets_exist, on: :show_app, if: :passenger_rails_app?

  def assets_exist
    errors.add(:base, 'Build missing assets with <strong>Precompile Assets</strong>') unless router.path.join('public',
                                                                                                              'assets').directory?
  end

  class << self
    def all
      router.apps.map { |a| new(name: a.name, found: true) }
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
