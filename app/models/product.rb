class Product
  include ActiveModel::Model

  ROUTER = {
    dev: DevRouter,
    usr: UsrRouter
  }

  attr_accessor :type
  attr_accessor :name
  attr_accessor :title
  attr_accessor :description

  validate :app_does_not_exist, on: :create_app

  def app_does_not_exist
    errors.add(:name, "already exists as an app") if router.path.exist?
  end

  class << self
    def all(type)
      ROUTER[type].apps.map {|a| Product.new(type: type, name: a.name)}
    end

    def find(type, name)
      Product.new(type: type, name: name)
    end
  end

  def app
    OodApp.new(router)
  end

  def router
    ROUTER[type].new(name) if type && name
  end

  def persisted?
    router && router.path.exist?
  end

  def new_record?
    !persisted?
  end

  def initialize(attributes={})
    super
    if persisted?
      @title ||= app.title
      @description ||= app.manifest.description
    end
  end

  def save
    if self.valid?(:create_app)
      stage
      write_manifest
    else
      false
    end
  end

  def update(attributes)
    @title = attributes[:title] if attributes[:title]
    @description = attributes[:description] if attributes[:description]
    write_manifest
  end

  def destroy
    router.path.rmtree
  end

  private
    def stage
      router.path.mkpath
    end

    def write_manifest
      File.open(router.path.join('manifest.yml'), 'w') do |f|
        f.write({
          'name' => title,
          'description' => description
        }.to_yaml)
      end
    end
end
