# Utility class for setting FACL user permissions.
class UserPermission < Permission
  class << self
    def all(product)
      acls(product).map do |e|
        name = e.user_owner_entry? ? OodSupport::User.new(File.stat(product.router.path).uid) : e.principle
        e.user_entry? ? new(product: product, name: name.to_s, owner: e.user_owner_entry?) : nil
      end.compact
    end

    def find(product, name)
      owner_name = OodSupport::User.new(File.stat(product.router.path).uid).to_s
      entry = acls(product).detect do |e|
        (e.user_entry? && e.principle.to_s == name) || (e.user_owner_entry? && owner_name == name)
      end
      raise Permission::NotFound unless entry
      new(product: product, name: name, owner: entry.user_owner_entry?)
    end
  end

  def principle_class
    OodSupport::User
  end
end
