# Helper for app permission pages.
module PermissionsHelper
  def permissions_title(context)
    if context == :user
      "User Permissions"
    elsif context == :group
      "Group Permissions"
    else
      "Undefined Title"
    end
  end
end
