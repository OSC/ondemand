# frozen_string_literal: true

# Utility class for setting FACL group permissions.
class GroupPermission < Permission
  class << self
    def all(product)
      acls(product).map do |e|
        name = e.group_owner_entry? ? OodSupport::Group.new(File.stat(product.router.path).gid) : e.principle
        e.group_entry? ? new(product: product, name: name.to_s, owner: e.group_owner_entry?) : nil
      end.compact
    end

    def find(product, name)
      owner_name = OodSupport::Group.new(File.stat(product.router.path).gid).to_s
      entry = acls(product).detect do |e|
        (e.group_entry? && e.principle.to_s == name) || (e.group_owner_entry? && owner_name == name)
      end
      raise Permission::NotFound unless entry

      new(product: product, name: name, owner: entry.group_owner_entry?)
    end
  end

  def group
    true
  end

  def principle_class
    OodSupport::Group
  end
end
