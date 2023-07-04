# frozen_string_literal: true

# Helper for app permission pages.
module PermissionsHelper
  def permissions_title(context)
    case context
    when :user
      'User Permissions'
    when :group
      'Group Permissions'
    else
      'Undefined Title'
    end
  end
end
