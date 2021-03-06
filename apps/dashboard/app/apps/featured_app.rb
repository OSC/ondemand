# A simple subclass of OodApp that overrides category
# and subcategory to allow for groupings other than what's
# provided in the app's manifest & definition.
class FeaturedApp < OodApp
  attr_reader :category, :subcategory, :token

  def self.from_ood_app(app, token: nil)
    FeaturedApp.new(app.router, token: token)
  end

  def initialize(router, category: "Apps", 
                         subcategory: I18n.t('dashboard.pinned_apps_title'),
                         token: nil)
    super(router)
    @category = category.to_s
    @subcategory = subcategory.to_s
    @token = token || router.token
  end

  protected

  # A featured app is only 1 app, singular. So it _is_ the configured sub-app.
  # As an example, we've configured sys/bc_desktop/pitzer.  Pitzer is a sub-app
  # of bc_desktop. We don't care if there are multiple bc_desktops sub-apps, only
  # pitzer is featured - so only _it_ should be returned in the sub-app list
  def sub_app_list
    if batch_connect.sub_app_list.size == 1
      batch_connect.sub_app_list
    else
      batch_connect.sub_app_list.select { |app| app.sub_app == sub_app_name }
    end
  end

  private

  def sub_app_name
    token.to_s.split("/").last
  end
end
