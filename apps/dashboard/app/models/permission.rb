# frozen_string_literal: true

# Parent class for setting FACL permissions on files or directories.
class Permission
  include ActiveModel::Model

  attr_accessor :product, :name, :owner

  validate :principle_exists, on: :create_permission
  validate :permission_does_not_exist, on: :create_permission
  validate :path_to_app_exists, on: [:create_permission, :destroy_permission]
  validate :not_owner_permission, on: [:create_permission, :destroy_permission]

  def principle_exists
    principle_class.new(name)
  rescue StandardError
    errors.add(:name, 'does not exist on the system')
  end

  def path_to_app_exists
    errors.add(:product, 'does not exist in the file system') unless product.router.path.exist?
  end

  def permission_does_not_exist
    errors.add(:name, 'is already given access to this product') if self.class.find(product, name)
  rescue StandardError
  end

  def not_owner_permission
    errors.add(:owner, "permission can't be removed") if owner
  end

  class NotFound < StandardError; end

  class << self
    def permission_types
      {
        user:  UserPermission,
        group: GroupPermission
      }
    end

    def build(arguments = {})
      context = arguments.delete(:context)
      raise ArgumentError, 'Need to specify context of permission' unless context

      permission_types[context].new arguments
    end

    def all(context, product)
      permission_types[context].all(product)
    end

    def find(context, product, name)
      permission_types[context].find(product, name)
    end

    def acls(product)
      product.router.path.exist? ? OodSupport::ACLs::Nfs4ACL.get_facl(path: product.router.path).entries : []
    rescue StandardError => e
      Rails.logger.error("cannot list facls for #{product.router.path}: #{e.class}:#{e.message}")
      []
    end
  end

  def group
    false
  end

  def save
    if valid?(:create_permission)
      add_entry
      errors.empty? ? true : false
    else
      false
    end
  end

  def destroy
    if valid?(:destroy_permission)
      rem_entry
      errors.empty? ? true : false
    else
      false
    end
  end

  private

  def acl_entry(principle)
    flags = []
    flags << :g if group
    OodSupport::ACLs::Nfs4Entry.new(type: :A, flags: flags, principle: principle.to_s, domain: facl_domain,
                                    permissions: [:r, :x])
  end

  def facl_domain
    Configuration.facl_domain
  end

  def add_entry
    OodSupport::ACLs::Nfs4ACL.add_facl(path: product.router.path, entry: acl_entry(name))
  rescue StandardError => e
    msg = "cannot add facl for #{name}@#{facl_domain}: #{e.class}:#{e.message}"
    errors.add(:name, msg)
    Rails.logger.error(msg)
  end

  def rem_entry
    OodSupport::ACLs::Nfs4ACL.rem_facl(path: product.router.path, entry: acl_entry(name))
  rescue StandardError => e
    msg = "cannot remove facl for #{name}@#{facl_domain}: #{e.class}:#{e.message}"
    errors.add(:name, msg)
    Rails.logger.error(msg)
  end
end
