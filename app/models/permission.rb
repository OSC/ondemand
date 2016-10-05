class Permission
  include ActiveModel::Model

  PERMISSION_TYPES = {
    user: UserPermission,
    group: GroupPermission
  }

  attr_accessor :product
  attr_accessor :name
  attr_accessor :owner

  validate :principle_exists, on: :create_permission
  validate :permission_does_not_exist, on: :create_permission
  validate :path_to_app_exists, on: [:create_permission, :destroy_permission]
  validate :not_owner_permission, on: [:create_permission, :destroy_permission]

  def principle_exists
    principle_class.new(name)
  rescue
    errors.add(:name, "does not exist on the system")
  end

  def path_to_app_exists
    errors.add(:product, "does not exist in the file system") unless product.router.path.exist?
  end

  def permission_does_not_exist
    errors.add(:name, "is already given access to this product") if self.class.find(product, name)
  rescue
  end

  def not_owner_permission
    errors.add(:owner, "permission can't be removed") if owner
  end

  class NotFound < StandardError; end

  class << self
    def build(arguments = {})
      context = arguments.delete(:context)
      raise ArgumentError, "Need to specify context of permission" unless context
      PERMISSION_TYPES[context].new arguments
    end

    def all(context, product)
      PERMISSION_TYPES[context].all(product)
    end

    def find(context, product, name)
      PERMISSION_TYPES[context].find(product, name)
    end
  end

  def group
    false
  end

  def save
    if self.valid?(:create_permission)
      add_entry
      true
    else
      false
    end
  end

  def destroy
    if self.valid?(:destroy_permission)
      rem_entry
    else
      false
    end
  end

  private
    def self.acls(product)
      product.router.path.exist? ? OodSupport::ACLs::Nfs4ACL.get_facl(path: product.router.path).entries : []
    end

    def acl_entry(principle)
      flags = []
      flags << :g if group
      OodSupport::ACLs::Nfs4Entry.new(type: :A, flags: flags, principle: principle.to_s, domain: "osc.edu", permissions: [:r, :x])
    end

    def add_entry
      OodSupport::ACLs::Nfs4ACL.add_facl(path: product.router.path, entry: acl_entry(name))
    end

    def rem_entry
      OodSupport::ACLs::Nfs4ACL.rem_facl(path: product.router.path, entry: acl_entry(name))
    end
end
