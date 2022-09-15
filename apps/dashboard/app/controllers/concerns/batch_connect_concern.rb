# Concerns for the batch connect controllers.
module BatchConnectConcern
  extend ActiveSupport::Concern

  def bc_sys_app_groups
    OodAppGroup.groups_for(
      apps: nav_sys_apps.select(&:batch_connect_app?)
    )
  end

  def bc_usr_app_groups
    apps = nav_usr_apps.select(&:batch_connect_app?)
    if apps.empty?
      []
    else
      [ OodAppGroup.new(title: t('dashboard.shared_apps_title'), apps: apps) ]
    end
  end

  def bc_dev_app_groups
    OodAppGroup.groups_for(
      apps: nav_dev_apps.select(&:batch_connect_app?)
    )
  end
end
