class Product
  include ActiveModel::Model

  ROUTER = {
    dev: DevRouter,
    usr: UsrRouter
  }

  attr_accessor :app

  class << self
    def all(type)
      ROUTER[type.to_sym].apps.map {|a| Product.new(app: a)}
    end

    def find(type, id)
      Product.new(
        app: OodApp.new(ROUTER[type.to_sym].new(id))
      )
    end
  end

  def id
    app.name
  end

  def type
    app.type
  end
end
