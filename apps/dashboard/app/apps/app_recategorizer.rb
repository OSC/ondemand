# frozen_string_literal: true

# Wrapper around OodApp to override category and subcategory.
# This is to create artificial groups and subgroups for a custom navigation.
class AppRecategorizer < SimpleDelegator
  class << self
    def recategorize(apps, category, subcategory)
      apps.map do |app|
        AppRecategorizer.new(app, category: category, subcategory: subcategory)
      end
    end
  end

  def initialize(ood_app, category: nil, subcategory: nil, token: nil)
    super(ood_app)
    @inner_category = category || ood_app.category
    @inner_subcategory = subcategory || ood_app.subcategory
    @inner_token = token || ood_app.token
  end

  def category
    inner_category
  end

  def subcategory
    inner_subcategory
  end

  def token
    inner_token
  end

  def links
    if has_sub_apps?
      # Recategorized Apps (i.e., pinned apps) are one app - singular. So they
      # only have 1 link becuase they _are_ the configured sub-app.
      #
      # As an example, we've configured sys/bc_desktop/pitzer.  Pitzer is a sub-app
      # of bc_desktop. We don't care if there are multiple bc_desktops sub-app links,
      # only pitzer is configured - so only _it's_ link should be returned.
      app = sub_app_list.select do |sub|
        sub.valid? && sub.sub_app == sub_app_name
      end.first

      app.nil? ? [] : [app.link]
    else
      __getobj__.links
    end
  end

  private

  attr_reader :inner_category, :inner_subcategory, :inner_token

  def sub_app_name
    token.to_s.split('/').last
  end
end
